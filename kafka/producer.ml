open Lwt.Infix

let username = ref "__placeholder_username__"
let password = ref "__placeholder_password__"

let brokers = ref "localhost:9092"
let metadata = ref "metadata.broker.list"
let partition = ref 0

let topic = ref "__placeholder_topic__"
let message = ref "__placeholder_message__"

let main metadata broker topic message partition username password =
  let config = [
    metadata, broker ;
    "security.protocol", "SASL_PLAINTEXT" ;
    "sasl.mechanism", "PLAIN" ;
    "sasl.username", username ;
    "sasl.password", password
  ] in

  let producer = Kafka_lwt.new_producer config in
  let topic = Kafka.new_topic producer topic [] in
  Kafka_lwt.produce topic partition message >>= fun () ->
  Lwt.return ()

let usage_msg =
"usage ./producer --topic TOPICNAME --brokers URI:PORT \
  --message MESSAGE --metadata METADATA --partition PARTITION "

let speclist =
  [ ("--topic", Arg.Set_string topic, "doc topic todo");
    ("--brokers", Arg.Set_string brokers, "doc brokers todo") ;
    ("--message", Arg.Set_string message, "doc message todo") ;
    ("--username", Arg.Set_string username, "doc partition todo") ;
    ("--password", Arg.Set_string password, "doc partition todo") ;
    ("--metadata", Arg.Set_string metadata, "doc metadata todo") ;
    ("--partition", Arg.Set_int partition, "doc partition todo")
  ]

let () =
  Arg.parse speclist (fun _s -> ()) usage_msg;
  main !metadata !brokers !topic !message !partition !username !password
  |> Lwt_main.run
