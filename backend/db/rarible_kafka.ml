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

let kafka_config = ref None

let set_config config =
  let open Rtypes in
  kafka_config :=
  Some [
    "metadata.broker.list", config.kafka_broker ;
    "security.protocol", "SASL_PLAINTEXT" ;
    "sasl.mechanism", "PLAIN" ;
    "sasl.username", config.kafka_username ;
    "sasl.password", config.kafka_password ;
  ]

let read_kafka_config f =
  try
    let ic = open_in f in
    let json = Ezjsonm.from_channel ic in
    close_in ic;
    Lwt.return_ok (Json_encoding.destruct Rtypes.kafka_config_enc json)
  with exn -> Crp.rerr (`cannot_parse_config exn)

let may_set_kafka_config f =
  let open Let in
  match f with
  | "" -> Lwt.return_ok ()
  | _ ->
    let|>? c = read_kafka_config f in
    set_config c

(** Configuration *)
let get_config () = match !kafka_config with
  | None -> failwith "Kafka config is not setup"
  | Some c -> c

let create topic =
  let kafka_config = get_config () in
  let producer = Kafka_lwt.new_producer kafka_config in
  let topic = Kafka.new_topic producer topic [] in
  Lwt.return topic

let kafka_produce ?(partition=0) topic message =
  Kafka_lwt.produce topic partition message

(** Producer *)
let produce_item_event msg =
  match !kafka_config with
  | Some _c ->
    begin match !topic_item with
      | None -> create topic_item_name
      | Some t -> Lwt.return t
    end >>= fun t ->
    kafka_produce t msg
  | None -> Lwt.return ()

let produce_ownership_event msg =
  match !kafka_config with
  | Some _c ->
    begin match !topic_ownership with
      | None -> create topic_ownership_name
      | Some t -> Lwt.return t
    end >>= fun t ->
    kafka_produce t msg
  | _ -> Lwt.return ()

let produce_order_event order_event =
  match !kafka_config with
  | Some _c ->
    begin match !topic_order with
      | None -> create topic_order_name
      | Some t -> Lwt.return t
    end >>= fun t ->
    EzEncoding.construct Rtypes.order_event_enc order_event
    |> kafka_produce t
  | _ -> Lwt.return ()

let produce_activity activity =
  match !kafka_config with
  | Some _c ->
    begin match !topic_activity with
      | None -> create topic_activity_name
      | Some t -> Lwt.return t
    end >>= fun t ->
    EzEncoding.construct Rtypes.nft_activity_enc activity
    |> kafka_produce t
  | None -> Lwt.return ()

let produce_test msg =
  match !kafka_config with
  | Some _c ->
    begin match !topic_test with
      | None -> create topic_test_name
      | Some t -> Lwt.return t
    end >>= fun t ->
    kafka_produce t msg
  | _ -> Lwt.return ()
