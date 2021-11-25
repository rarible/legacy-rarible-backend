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

let max_message_bytes = string_of_int @@ 5 * 1024 * 1024

let set_config config =
  let open Rtypes in
  kafka_config :=
  Some [
    "message.max.bytes", max_message_bytes ;
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

let kafka_produce ?(partition=0) ?key topic message =
  Kafka_lwt.produce ?key topic partition message

(** Producer *)
let produce_item_event item_event =
  match !kafka_config with
  | Some _c ->
    begin match !topic_item with
      | None ->
        create topic_item_name >>= fun t ->
        topic_item := Some t ;
        Lwt.return t
      | Some t -> Lwt.return t
    end >>= fun t ->
    EzEncoding.construct Rtypes.nft_item_event_enc item_event
    |> kafka_produce ~key:item_event.Rtypes.nft_item_event_item_id t
  | None -> Lwt.return ()

let produce_ownership_event ownership_event =
  match !kafka_config with
  | Some _c ->
    begin match !topic_ownership with
      | None ->
        create topic_ownership_name >>= fun t ->
        topic_ownership := Some t ;
        Lwt.return t
      | Some t -> Lwt.return t
    end >>= fun t ->
    EzEncoding.construct Rtypes.nft_ownership_event_enc ownership_event
    |> kafka_produce ~key:ownership_event.Rtypes.nft_ownership_event_event_id t
  | _ -> Lwt.return ()

let produce_order_event ~decs:(maked, taked) order_event  =
  match !kafka_config with
  | Some _c ->
    begin match !topic_order with
      | None ->
        create topic_order_name >>= fun t ->
        topic_order := Some t ;
        Lwt.return t
      | Some t -> Lwt.return t
    end >>= fun t ->
    let order_event = Common.Balance.dec_order_event ?maked ?taked order_event in
    EzEncoding.construct Rtypes.(order_event_enc A.big_decimal_enc) order_event
    |> kafka_produce ~key:order_event.Rtypes.order_event_order_id t
  | _ -> Lwt.return ()

let produce_nft_activity nft_activity =
  let open Rtypes in
  match !kafka_config with
  | Some _c ->
    begin match !topic_activity with
      | None ->
        create topic_activity_name >>= fun t ->
        topic_activity := Some t ;
         Lwt.return t
      | Some t -> Lwt.return t
    end >>= fun t ->
    let activity = {
      activity_id = nft_activity.nft_act_id ;
      activity_date = nft_activity.nft_act_date ;
      activity_source = nft_activity.nft_act_source;
      activity_type = NftActivityType nft_activity.nft_act_type ;
    } in
    let activity = Common.Balance.dec_activity_type activity in
    EzEncoding.construct Rtypes.(activity_type_enc A.big_decimal_enc) activity
    |> kafka_produce ~key:activity.activity_id t
  | None -> Lwt.return ()

let produce_order_activity ~decs:(maked, taked) activity =
  let open Rtypes in
  match !kafka_config with
  | Some _c ->
    begin match !topic_activity with
      | None ->
        create topic_activity_name >>= fun t ->
        topic_activity := Some t ;
        Lwt.return t
      | Some t -> Lwt.return t
    end >>= fun t ->
    let activity = {
      activity_id = activity.order_act_id ;
      activity_date = activity.order_act_date ;
      activity_source = activity.order_act_source ;
      activity_type = OrderActivityType activity.order_act_type ;
    } in
    let activity = Common.Balance.dec_activity_type ?maked ?taked activity in
    EzEncoding.construct Rtypes.(activity_type_enc A.big_decimal_enc) activity
    |> kafka_produce ~key:activity.activity_id t
  | None -> Lwt.return ()

let produce_test msg =
  match !kafka_config with
  | Some _c ->
    begin match !topic_test with
      | None ->
        create topic_test_name >>= fun t ->
        topic_test := Some t ;
        Lwt.return t
      | Some t -> Lwt.return t
    end >>= fun t ->
    kafka_produce t msg
  | _ -> Lwt.return ()
