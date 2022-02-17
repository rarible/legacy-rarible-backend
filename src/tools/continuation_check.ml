open Let
open Rtypes

let api = ref "http://localhost:8080"
let size = ref 20
let deleted = ref true

let spec = [
  "--api", Arg.Set_string api, "Url of the API";
  "--size", Arg.Set_int size, "set size" ;
  "--deleted", Arg.Set deleted, "show deleted" ;
]

let usage =
  "usage: " ^ Sys.argv.(0) ^ " [--api url]"

let handle_ezreq_result = function
  | Ok x -> Ok x
  | Error (EzReq_lwt_S.UnknownError {msg; _}) ->
    Error {Api.Errors.code=`UNEXPECTED_API_ERROR; message=match msg with None -> "" | Some s -> s}
  | Error (EzReq_lwt_S.KnownError {error; _}) -> Error error

let loop () =
  let open EzAPI in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ Api.size_param, I !size ; Api.show_deleted_param, B !deleted ]
      | Some c ->
        [ Api.continuation_param, S c ; Api.size_param, I !size ; Api.show_deleted_param, B !deleted ] in
    let> r = EzReq_lwt.get0 url ~params Api.get_nft_all_items_s in
    let>? items = Lwt.return @@ handle_ezreq_result r in
    match items.nft_items_continuation with
    | None ->
      Format.eprintf "[loop] %d new items@." (List.length items.nft_items_items) ;
      let> _ = EzReq_lwt.get0 ~msg:"last" url ~params Api.get_nft_all_items_s in
      Lwt.return_ok @@ items.nft_items_items @ acc
    | Some continuation ->
      Format.eprintf "[loop] %d new items (total %d) | continuation %s@."
        (List.length items.nft_items_items) (List.length acc) continuation ;
      aux ~continuation (items.nft_items_items @ acc) in
  aux []

let () =
  Arg.parse spec (fun _ -> ()) usage;
  EzCurl_common.set_timeout (Some 3);
  Lwt_main.run @@ Lwt.map (Result.iter_error Crp.print_error) @@
  let> items = loop () in
  match items with
  | Ok items ->
    Format.eprintf "end with %d items@." @@ List.length items ;
    Lwt.return_ok ()
  | Error err ->
    Format.eprintf "ERROR %s@." @@ Api.Errors.string_of_error err ;
    Lwt.return_ok ()

