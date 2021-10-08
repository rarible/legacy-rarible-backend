open Lwt.Infix

(** Kafka Topics *)
let topic_item_name = "tezos-item"
let topic_order_name = "tezos-order"
let topic_activity_name = "tezos-activity"
let topic_ownership_name = "tezos-ownership"
let topic_test_name = "rarible-tezos-topic"

(** Configuration *)
let get_config () = [
    "metadata.broker.list", "127.0.0.1" ;
    "security.protocol", "SASL_PLAINTEXT" ;
    "sasl.mechanism", "PLAIN" ;
    "sasl.username", "rarible" ;
    "sasl.password", "PLgiE%np@v7Y^SqtqMA8eN^F4NNjk87$"
]

let create topic =
  let kafka_config = get_config () in
  let producer = Kafka_lwt.new_producer kafka_config in
  let topic = Kafka.new_topic producer topic [] in
  Lwt.return topic

let topic_item =
  create topic_item_name

let topic_order =
  create topic_order_name

let topic_activity =
  create topic_activity_name

let topic_ownership =
  create topic_ownership_name

let topic_test =
  create topic_test_name

let kafka_produce ?(partition=0) topic message =
  Kafka_lwt.produce topic partition message

(** Producer *)
let produce_item_event msg =
  topic_item >>= fun topic ->
  kafka_produce topic msg

let produce_ownership_event msg  =
  topic_ownership >>= fun topic ->
  kafka_produce topic msg

let produce_order_event order_event =
  topic_order >>= fun topic ->
  EzEncoding.construct Rtypes.order_event_enc order_event
  |> kafka_produce topic

let produce_activity activity =
  topic_activity >>= fun topic ->
  EzEncoding.construct Rtypes.nft_activity_enc activity
  |> kafka_produce topic

let produce_test msg =
  topic_test >>= fun topic ->
  kafka_produce topic msg
