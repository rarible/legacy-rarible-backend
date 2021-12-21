open Tzfunc
open Proto
open Crypto
open Rtypes
open Let

let filename = ref None
let port = ref 8081

type config = {
  secret_key: string;
  transfer_proxy: string;
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
  left: A.big_decimal order;
  right: A.big_decimal order;
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

let usage = "permit.exe config.json"
let spec = [
  "--port", Arg.Set_int port, "Port of API server";
]

let config =
  ref {
    secret_key = "";
    transfer_proxy = "";
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

let mk_ops ?(fee=0L) ?(counter=Z.zero) ?(gas_limit=Z.zero) ?(storage_limit=Z.zero)
    ?(amount=0L) ?metadata ~source ~destination ~entrypoint params =
  let parameters = Some { entrypoint = EPnamed entrypoint; value = Micheline params } in
  [ {
    man_info = { source; kind = Transaction { amount; destination; parameters } };
    man_numbers = { fee; counter; gas_limit; storage_limit };
    man_metadata = metadata } ]

let inject_ops ~code ops =
  let get_pk () = Lwt.return_ok !config.edpk in
  let sign bytes = Node.sign ~edsk:!config.edsk bytes in
  let> r =
    Node.forge_manager_operations ~base:(EzAPI.BASE !config.node) ~get_pk
      ~src:!config.tz1 ops in
  match r with
  | Error e ->
    EzAPIServer.return (Error { code; message = Rp.string_of_error e })
  | Ok (bytes, protocol, branch, ops) ->
    let> r = Node.inject ~base:(EzAPI.BASE !config.node) ~sign ~bytes ~branch ~protocol ops in
    match r with
    | Error e ->
      EzAPIServer.return (Error { code; message = Rp.string_of_error e })
    | Ok hash ->
      EzAPIServer.return (Ok hash)

let add_permit permit =
  let ops = mk_ops ~entrypoint:"permit" ~source:!config.tz1 ~destination:permit.contract
      (Mseq [ Mstring permit.pk; Mstring permit.signature; Mbytes (H.mk permit.hash)]) in
  inject_ops ~code:`PERMIT_ERROR ops
[@@post
  {path="/v0.1/permit/add";
   input=permit_enc;
   output=Json_encoding.string;
   name="add_permit";
   errors=[permit_error_case];
   section=permit_section}]

let z_order order =
  let>? maked = Db.get_decimals ~do_error:true order.order_elt.order_elt_make.asset_type in
  let|>? taked = Db.get_decimals ~do_error:true order.order_elt.order_elt_take.asset_type in
  Common.Balance.z_order ?maked ?taked order

let match_orders orders =
  let> rleft = z_order orders.left in
  let> rright = z_order orders.right in
  match rleft, rright with
  | Error e, _ | _, Error e ->
    EzAPIServer.return (Error { code = `ORDER_ERROR; message = Crp.string_of_error e })
  | Ok left, Ok right ->
    match Common.Utils.flat_order left, Common.Utils.flat_order right with
    | Error e, _ | _, Error e ->
      EzAPIServer.return (Error { code = `ORDER_ERROR; message = Let.string_of_error e })
    | Ok m_left, Ok m_right ->
      let signature_left =
        Forge.prim `Some ~args:[Mstring left.order_elt.order_elt_signature] in
      let signature_right =
        Forge.prim `Some ~args:[Mstring right.order_elt.order_elt_signature] in
      let mich = Forge.prim `Pair ~args:[m_left; signature_left; m_right; signature_right] in
      let ops = mk_ops ~entrypoint:"match_orders" ~source:!config.tz1 ~destination:!config.exchange
          mich in
      inject_ops ~code:`ORDER_ERROR ops
[@@post
  {path="/v0.1/permit/match_orders";
   input=orders_enc;
   output=Json_encoding.string;
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
