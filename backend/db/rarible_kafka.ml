open Lwt.Infix

(** Kafka Topics *)
let topic_item_name = "tezos-item"
let topic_order_name = "tezos-order"
let topic_activity_name = "tezos-activity"
let topic_ownership_name = "tezos-ownership"
let topic_test_name = "rarible-tezos-topic"

let topic_item = ref None
let topic_order = ref None
let topic_activity = ref None
let topic_ownership = ref None
let topic_test = ref None


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

(** Producer *)
let produce_item_event msg =
  match Sys.getenv_opt "RARIBLE_KAFKA_TEZOS" with
  | Some str when str <> "" ->
    begin match !topic_item with
      | None -> create topic_item_name
      | Some t -> Lwt.return t
    end >>= fun t ->
    kafka_produce t msg
  | _ -> Lwt.return ()

let produce_ownership_event msg =
  match Sys.getenv_opt "RARIBLE_KAFKA_TEZOS" with
  | Some str when str <> "" ->
    begin match !topic_ownership with
      | None -> create topic_ownership_name
      | Some t -> Lwt.return t
    end >>= fun t ->
    kafka_produce t msg
  | _ -> Lwt.return ()

let produce_order_event order_event =
  match Sys.getenv_opt "RARIBLE_KAFKA_TEZOS" with
  | Some str when str <> "" ->
    begin match !topic_order with
      | None -> create topic_order_name
      | Some t -> Lwt.return t
    end >>= fun t ->
    EzEncoding.construct Rtypes.order_event_enc order_event
    |> kafka_produce t
  | _ -> Lwt.return ()

let produce_activity activity =
  match Sys.getenv_opt "RARIBLE_KAFKA_TEZOS" with
  | Some str when str <> "" ->
    begin match !topic_activity with
      | None -> create topic_activity_name
      | Some t -> Lwt.return t
    end >>= fun t ->
    EzEncoding.construct Rtypes.nft_activity_enc activity
    |> kafka_produce t
  | _ -> Lwt.return ()

let produce_test msg =
  match Sys.getenv_opt "RARIBLE_KAFKA_TEZOS" with
  | Some str when str <> "" ->
    begin match !topic_test with
      | None -> create topic_test_name
      | Some t -> Lwt.return t
    end >>= fun t ->
    kafka_produce t msg
  | _ -> Lwt.return ()
