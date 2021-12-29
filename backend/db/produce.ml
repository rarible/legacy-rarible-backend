open Let
open Rtypes
open Common
open Misc

let order_event_hash dbh hash () =
  match !Rarible_kafka.kafka_config with
  | None -> Lwt.return_ok ()
  | Some _ ->
    let>? order = Get.get_order ~dbh hash in
    begin
      match order with
      | Some (order, decs) ->
        Rarible_kafka.produce_order_event ~decs (Utils.mk_order_event order)
      | None -> Lwt.return ()
    end >>= fun () ->
    Lwt.return_ok ()

let order_event_item dbh old_owner contract token_id () =
  match !Rarible_kafka.kafka_config with
  | None -> Lwt.return_ok ()
  | Some _ ->
    let>? l =
      [%pgsql.object dbh
          "select hash from orders \
           where make_asset_type_contract = $contract and \
           make_asset_type_token_id = ${Z.to_string token_id} and \
           maker = $old_owner"] in
    iter_rp (fun r ->
        let>? order = Get.get_order ~dbh r#hash in
        match order with
        | None -> Lwt.return_ok ()
        | Some (order, decs) ->
          match order.order_elt.order_elt_status with
          | OINACTIVE | OACTIVE ->
            Rarible_kafka.produce_order_event ~decs (Utils.mk_order_event order) >>= fun () ->
            Lwt.return_ok ()
          | _ -> Lwt.return_ok ())
      l

let nft_item_event dbh contract token_id () =
  match !Rarible_kafka.kafka_config with
  | None -> Lwt.return_ok ()
  | Some _ ->
    let> item = Get.get_nft_item_by_id ~dbh ~include_meta:true contract token_id in
    match item with
    | Ok item ->
      if item.nft_item_supply = Z.zero then
        Rarible_kafka.produce_item_event (Utils.mk_delete_item_event item)
        >>= fun () ->
        Lwt.return_ok ()
      else
        Rarible_kafka.produce_item_event (Utils.mk_update_item_event item)
        >>= fun () ->
        Lwt.return_ok ()
    | Error err ->
      Printf.eprintf "couldn't produce nft event %S\n%!" @@ Crp.string_of_error err ;
      Lwt.return_ok ()

let nft_collection_event c =
  match !Rarible_kafka.kafka_config with
  | None -> Lwt.return_ok ()
  | Some _ ->
    Rarible_kafka.produce_collection_event (Utils.mk_nft_collection_event c)
    >>= fun () ->
    Lwt.return_ok ()

let update_collection_event dbh contract () =
  match !Rarible_kafka.kafka_config with
  | None -> Lwt.return_ok ()
  | Some _ ->
    let> c = Get.get_nft_collection_by_id ~dbh contract in
    match c with
    | Ok c -> nft_collection_event c
    | Error e ->
      Printf.eprintf "couldn't produce collection event %S\n%!" @@ Crp.string_of_error e ;
      Lwt.return_ok ()

let nft_ownership_update_event os =
  if os.nft_ownership_value = Z.zero then
    Rarible_kafka.produce_ownership_event (Utils.mk_delete_ownership_event os)
  else
    Rarible_kafka.produce_ownership_event (Utils.mk_update_ownership_event os)

let nft_ownership_event dbh contract token_id owner () =
  match !Rarible_kafka.kafka_config with
  | None -> Lwt.return_ok ()
  | Some _ ->
    begin
      Get.get_nft_ownership_by_id
        ~old:true ~dbh contract token_id owner >>= function
      | Ok os -> nft_ownership_update_event os
      | Error err ->
        Printf.eprintf "Couldn't produce ownership event %S\n%!" @@ Crp.string_of_error err ;
        Lwt.return_unit
    end >>= fun () ->
    Lwt.return_ok ()

let cancel_events dbh main l =
  iter_rp (fun r ->
      if main then
        match r#cancel with
        | None -> Lwt.return_ok ()
        | Some h ->
          order_event_hash dbh h ()
      else Lwt.return_ok ())
    l

let match_events dbh main l =
  iter_rp (fun r ->
      if main then
        let>? () = order_event_hash dbh r#hash_left () in
        order_event_hash dbh r#hash_right ()
      else Lwt.return_ok ())
    l

let nft_activity_events main l =
  iter_rp (fun r ->
      if main then
        let>? ev = Get.mk_nft_activity r in
        let activity = { at_nft_type = Some ev ; at_order_type = None } in
        Rarible_kafka.produce_activity ~decs:(None,None) activity >>= fun () ->
        Lwt.return_ok ()
      else Lwt.return_ok ())
    l

let collection_events main l =
  iter_rp (fun r ->
      if main then
        match Get.mk_nft_collection r with
        | Ok c ->
          nft_collection_event c
        | Error err ->
          Printf.eprintf "couldn't produce collection event %S\n%!" @@ Crp.string_of_error err ;
          Lwt.return_ok ()
      else Lwt.return_ok ())
    l
