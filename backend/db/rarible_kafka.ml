open Lwt.Infix

(** Kafka Topics *)
let topic_item_name = "tezos-item"
let topic_order_name = "tezos-order"
let topic_activity_name = "tezos-activity"
let topic_ownership_name = "tezos-ownership"
let topic_test = "rarible-tezos-topic"

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

let kafka_produce ?(partition=0) topic message =
  Kafka_lwt.produce topic partition message

let kafka_produce topic ev =
  create topic >>= fun topic ->
  kafka_produce topic ev

(** Producer *)
let produce_item_event msg =
  kafka_produce topic_item_name msg

let produce_ownership_event msg  =
  kafka_produce topic_ownership_name msg

let produce_order_event order_event =
  EzEncoding.construct Rtypes.order_event_enc order_event
  |> kafka_produce topic_order_name

let produce_activity activity =
  EzEncoding.construct Rtypes.nft_activity_enc activity
  |> kafka_produce topic_activity_name

let produce_test msg =
  kafka_produce topic_test msg
