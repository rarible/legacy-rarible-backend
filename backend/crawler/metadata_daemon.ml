open Let
open Common
open Proto

let contract = ref None
let retrieve  = ref false
let node = ref "https://tz.functori.com"

let spec = [
  "--contract", Arg.String (fun s -> contract := Some s),
  "Only try to reset metadata for this contract";
  "--retrieve-context", Arg.Set retrieve,
  "Retrieve unknown metadata from context";
  "--node", Arg.Set_string node,
  "Node to use to retrieve metadata from context";
]

let retrieve_token_metadata ~token_metadata_id ~token_id =
  let> r = Tzfunc.Node.(
      get_big_map_value ~base:(EzAPI.BASE !node)
        ~typ:(prim `nat) token_metadata_id (Mint token_id)) in
  match r with
  | Error e ->
    Format.eprintf "Cannot retrieve metadata:\n%s@." (Tzfunc.Rp.string_of_error e);
    Lwt.return None
  | Ok (Bytes _) | Ok (Other _) ->
    Format.eprintf "Wrong token metadata format@.";
    Lwt.return None
  | Ok (Micheline m) ->
    let _, value_type = Contract_spec.token_metadata_field in
    begin match Typed_mich.parse_value value_type m with
      | Ok (`tuple [`nat _; `assoc l]) ->
        Lwt.return (Some (Parameters.parse_metadata l))
      | _ ->
        Format.eprintf "Wrong token metadata type@.";
        Lwt.return None
    end

let () =
  Lwt_main.run @@ Lwt.map (fun _ -> ()) @@
  let>? () =
    if !retrieve then
      let>? l = Db.empty_token_metadata ?contract:!contract () in
      iter_rp (fun r ->
          let> metadata =


  Db.update_unknown_metadata ?contract:!contract ()
