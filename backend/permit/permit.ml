open Tzfunc
open Proto
open Crypto
open Rtypes
open Let

let filename = ref None
let port = ref 8081

type config = {
  secret_key: string;
  exchange: string;
  whitelist: string list; [@dft []]
  edsk: string; [@dft ""]
  edpk: string; [@dft ""]
  tz1: string; [@dft ""]
  node: string; [@dft "https://tz.functori.com"]
} [@@deriving encoding]

type permit = {
  hash: A.word;
  signature: A.edsig;
  pk: A.edpk;
  contract: A.address;
  expiry: A.timestamp option;
} [@@deriving encoding]

type orders = {
  left: A.big_decimal order_form;
  right: A.big_decimal order_form;
} [@@deriving encoding]

type error = {
  code: [ `PERMIT_ERROR | `ORDER_ERROR ];
  message: string;
} [@@deriving encoding]

let permit_error_case =
  EzAPI.Err.make ~code:400 ~name:"PermitError" ~encoding:error_enc
    ~select:(fun e -> match e.code with `PERMIT_ERROR -> Some e | _ -> None)
    ~deselect:(fun e -> e)

let order_error_case =
  EzAPI.Err.make ~code:400 ~name:"OrderError" ~encoding:error_enc
    ~select:(fun e -> match e.code with `ORDER_ERROR -> Some e | _ -> None)
    ~deselect:(fun e -> e)

let hash_enc = Json_encoding.(obj1 (req "hash" string))

let usage = "permit.exe config.json"
let spec = [
  "--port", Arg.Set_int port, "Port of API server";
]

let config =
  ref {
    secret_key = "";
    exchange = "";
    whitelist = [];
    edsk = "";
    edpk = "";
    tz1 = "";
    node = "https://tz.functori.com"
  }

let load_config filename =
  try
    let ic = open_in filename in
    let s = really_input_string ic (in_channel_length ic) in
    let c = EzEncoding.destruct config_enc s in
    if String.length c.secret_key < 5 then
      failwith "wrong secret key format"
    else
      let sk =
        if String.sub c.secret_key 0 4 = "edsk" then
          match Sk.b58dec c.secret_key with
          | Error _ -> failwith "wrong secret key format"
          | Ok sk -> sk
        else if String.sub c.secret_key 0 5 = "edesk" then
          let esk = Base58.decode ~prefix:Prefix.ed25519_encrypted_seed c.secret_key in
          Format.printf "Password for secret key:@.";
          let password = read_line () in
          match Box.decrypt ~password (Bigstring.of_string (esk :> string)) with
          | None -> failwith "error in secret key decryption"
          | Some sk -> Sk.T.mk @@ Raw.mk (Bigstring.to_string sk)
        else failwith "wrong secret key format" in
      let pk = Sk.to_public_key sk in
      let pkh = Pk.hash pk in
      let edsk = Sk.b58enc ~curve:`ed25519 sk in
      let edpk = Pk.b58enc ~curve:`ed25519 pk in
      let tz1 = Pkh.b58enc ~curve:`ed25519 pkh in
      config := {c with edsk; edpk; tz1};
      Ok ()
  with exn -> Error (`config_error exn)

let permit_section =
  EzAPI.Doc.{section_name = "permit-controller"; section_docs = []}
let sections = [ permit_section ]


let inject_ops ~code ops =
  let get_pk () = Lwt.return_ok !config.edpk in
  let sign bytes = Node.sign ~edsk:!config.edsk bytes in
  let> r = Utils.send ~base:(EzAPI.BASE !config.node) ~get_pk ~sign ops in
  match r with
  | Error e ->
    EzAPIServer.return (Error { code; message = Rp.string_of_error e })
  | Ok hash ->
    EzAPIServer.return (Ok hash)

let add_permit permit =
  if List.mem permit.contract !config.whitelist then
    let param = Micheline (Mseq [ Mstring permit.pk; Mstring permit.signature; Mbytes (H.mk permit.hash)]) in
    let ops = [ Utils.transaction ~entrypoint:"permit" ~source:!config.tz1 ~param permit.contract ] in
    inject_ops ~code:`PERMIT_ERROR ops
  else
    let message = Format.sprintf "contract %s not whitelisted for feeless transaction" permit.contract in
    EzAPIServer.return (Error { code = `PERMIT_ERROR; message })
[@@post
  {path="/v0.1/permit/add";
   input=permit_enc;
   output=hash_enc;
   name="add_permit";
   errors=[permit_error_case];
   section=permit_section}]

let flat_order_form order =
  let maker = order.order_form_elt.order_form_elt_maker_edpk in
  let make = order.order_form_elt.order_form_elt_make in
  let taker = order.order_form_elt.order_form_elt_taker_edpk in
  let take = order.order_form_elt.order_form_elt_take in
  let salt = order.order_form_elt.order_form_elt_salt in
  let start_date = order.order_form_elt.order_form_elt_start in
  let end_date = order.order_form_elt.order_form_elt_end in
  Common.Utils.flat_order_type
    ~maker ~make ~taker ~take ~salt ~start_date ~end_date
    ~data_type:"V1"
    ~payouts:order.order_form_data.order_rarible_v2_data_v1_payouts
    ~origin_fees:order.order_form_data.order_rarible_v2_data_v1_origin_fees

let z_order_form order =
  let>? maked = Db.get_decimals ~do_error:true order.order_form_elt.order_form_elt_make.asset_type in
  let|>? taked = Db.get_decimals ~do_error:true order.order_form_elt.order_form_elt_take.asset_type in
  Common.Balance.z_order_form ?maked ?taked order

let get_contract = function
  | ATXTZ -> assert false
  | ATFT { contract; _ } | ATNFT { asset_contract=contract; _ }
  | ATMT { asset_contract=contract; _ } -> contract

let match_orders orders =
  match orders.left.order_form_elt.order_form_elt_make.asset_type,
        orders.right.order_form_elt.order_form_elt_make.asset_type with
  | ATXTZ, _ | _, ATXTZ ->
    let message = "XTZ transfer not possible for feeless transaction" in
    EzAPIServer.return (Error { code = `ORDER_ERROR; message })
  | _ ->
    let contract_left = get_contract orders.left.order_form_elt.order_form_elt_make.asset_type in
    let contract_right = get_contract orders.right.order_form_elt.order_form_elt_make.asset_type in
    if List.mem contract_left !config.whitelist || List.mem contract_right !config.whitelist then
      let> rleft = z_order_form orders.left in
      let> rright = z_order_form orders.right in
      match rleft, rright with
      | Error e, _ | _, Error e ->
        EzAPIServer.return (Error { code = `ORDER_ERROR; message = Crp.string_of_error e })
      | Ok left, Ok right ->
        match flat_order_form left, flat_order_form right with
        | Error e, _ | _, Error e ->
          EzAPIServer.return (Error { code = `ORDER_ERROR; message = Let.string_of_error e })
        | Ok m_left, Ok m_right ->
          let signature_left =
            Forge.prim `Some ~args:[Mstring left.order_form_elt.order_form_elt_signature] in
          let signature_right =
            Forge.prim `Some ~args:[Mstring right.order_form_elt.order_form_elt_signature] in
          let param = Micheline (Forge.prim `Pair ~args:[m_left; signature_left; m_right; signature_right]) in
          let ops = [ Utils.transaction ~entrypoint:"match_orders" ~source:!config.tz1 ~param !config.exchange ] in
          inject_ops ~code:`ORDER_ERROR ops
    else
      let message = Format.sprintf "No contract whitelisted in order (%s, %s)"
          contract_left contract_right in
      EzAPIServer.return (Error { code = `ORDER_ERROR; message })
[@@post
  {path="/v0.1/permit/match_orders";
   input=orders_enc;
   output=hash_enc;
   name="match_orders";
   errors=[order_error_case];
   section=permit_section}]

let () =
  Arg.parse [] (fun s -> filename := Some s) usage;
  EzLwtSys.run @@ fun () ->
  match !filename with
  | None -> Format.eprintf "No config file given@."; exit 1
  | Some filename -> match load_config filename with
    | Error (`config_error exn) ->
      Format.eprintf "Cannot load config from %s\n%s@." filename (Printexc.to_string exn);
      exit 1
    | Ok () ->
      EzAPIServer.server [ !port, EzAPIServerUtils.API ppx_dir ]
