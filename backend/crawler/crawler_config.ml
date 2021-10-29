open Crawlori

let get file extra_enc =
  match file with
  | None ->
    Error `no_config
  | Some f ->
    try Ok (EzEncoding.destruct (Config.enc extra_enc) f)
    with _ ->
      try
        let ic = open_in f in
        let s = really_input_string ic (in_channel_length ic) in
        let config = EzEncoding.destruct (Config.enc extra_enc) s in
        Ok config
      with exn ->
        Error (`cannot_parse_config exn)
