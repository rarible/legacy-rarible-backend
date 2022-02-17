open Api
open Let

let kafka_config_file = ref ""
let port = ref 8080

let args = [
  ("--kafka-config", Arg.Set_string kafka_config_file, "set kafka configuration");
  ("--port", Arg.Set_int port, "set api port (default: 8080)")
]

let usage = "usage: " ^ Sys.argv.(0) ^ " [-kafka-config string]"

let () =
  Arg.parse args (fun str -> Printf.printf "don't know what to do with %S" str) usage ;
  EzLwtSys.run (fun () ->
      Db.Rarible_kafka.may_set_kafka_config !kafka_config_file >>= function
      | Ok () ->
        Format.printf "COMMIT_HASH=%s@." Version.version ;
        EzAPIServer.server [ !port, EzAPIServerUtils.API ppx_dir ]
      | Error err -> Lwt.fail_with @@ Crp.string_of_error err)
