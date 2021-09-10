open Lwt.Infix

let brokers = ref "localhost:9092"
let metadata = ref "metadata.broker.list"
let partition = ref 0

let topic = ref "__placeholder_topic__"
let message = ref "__placeholder_message__"

let main metadata brokers topic messages partition =
  let producer = Kafka_lwt.new_producer [ metadata, brokers ] in
  let topic = Kafka.new_topic producer topic [] in
  Kafka_lwt.produce topic partition messages >>= fun () ->
  Lwt.return ()

let usage_msg =
"usage ./producer --topic TOPICNAME --brokers URI:PORT \
  --message MESSAGE --metadata METADATA --partition PARTITION "

let speclist =
  [ ("--topic", Arg.Set_string topic, "doc topic todo");
    ("--brokers", Arg.Set_string brokers, "doc brokers todo") ;
    ("--message", Arg.Set_string message, "doc message todo") ;
    ("--metadata", Arg.Set_string metadata, "doc metadata todo") ;
    ("--partition", Arg.Set_int partition, "doc partition todo")
  ]

let () =
  Arg.parse speclist (fun _s -> ()) usage_msg;
  main !metadata !brokers !topic !message !partition
  |> Lwt_main.run
