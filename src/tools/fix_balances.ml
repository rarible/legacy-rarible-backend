open Let
open Tzfunc
open Proto

let kafka_config_file = ref ""

let get_balance ~block ~ledger_id ~key ~value ~token_id ~account =
  let x = match EzEncoding.destruct Mtyped.stype_enc.json key with
    | `nat -> Some (Node.prim `nat, Mint (Z.of_string token_id))
    | `tuple [`nat; `address] ->
      Some (Node.prim `pair ~args:[Node.prim `nat; Node.prim `address],
            Node.prim `Pair ~args:[Mint (Z.of_string token_id); Mstring account])
    |`tuple [`address; `nat] ->
      Some (Node.prim `pair ~args:[Node.prim `address; Node.prim `nat],
            Node.prim `Pair ~args:[Mstring account; Mint (Z.of_string token_id)])
    | _ -> None in
  match x with
  | None -> Lwt.return None
  | Some (typ, key) ->
    let|> r = Node.get_bigmap_value ~block ~typ ledger_id key in
    match EzEncoding.destruct Mtyped.stype_enc.json value, r with
    | `address, Ok (Some (Micheline (Mstring a))) when a = account -> Some Z.one
    | `address, Ok (Some (Micheline _)) -> Some Z.zero
    | `nat, Ok (Some (Micheline (Mint balance))) -> Some balance
    | _ -> None

let main () =
  let>? () = Db.Rarible_kafka.may_set_kafka_config !kafka_config_file in
  let>? (block, _) = Pg.head None in
  let>? l = Db.Utils.get_alt_token_balance_updates () in
  let tm = List.fold_left (fun tm r ->
      match r#account with
      | Some account ->
        let k = r#contract, Z.of_string r#token_id, account in
        Rtypes.TMap.update k (function None -> Some r | Some x -> Some x) tm
      | _ -> tm) Rtypes.TMap.empty l in
  let tim = Rtypes.TMap.fold (fun (contract, token_id, _) r tim ->
      let k = contract, token_id in
      Rtypes.TIMap.update k (function None -> Some r | Some x -> Some x) tim) tm Rtypes.TIMap.empty in
  let>? l =
    map_rp (fun (_, r) ->
        match r#account, r#ledger_key, r#ledger_value with
        | Some account, Some key, Some value ->
          Format.printf "Handle %s %s %s@." r#contract r#token_id account;
          let> b = get_balance ~block ~ledger_id:(Z.of_string r#ledger_id) ~key
              ~value ~token_id:r#token_id ~account in
          begin match b with
            | Some b ->
              let>? () =
                Db.Utils.update_token ~contract:r#contract
                  ~token_id:(Z.of_string r#token_id) ~account b in
              Lwt.return_ok @@ Some (r#contract, r#token_id, account)
            | _ -> Lwt.return_ok None
          end
        | _ -> Lwt.return_ok None) (Rtypes.TMap.bindings tm) in
  let>? () = iter_rp (fun (_, r) ->
      match r#account with
      | Some account ->
        Db.Utils.update_token_info ~contract:r#contract ~account
          ~token_id:(Z.of_string r#token_id) ~block:r#block ~level:r#level
          ~tsp:r#tsp ~transaction:r#transaction ()
      | _ -> Lwt.return_ok ()) (Rtypes.TIMap.bindings tim) in
  Db.Misc.use None @@ fun dbh ->
  fold_rp (fun acc (c, tid, account) ->
      let tid = Z.of_string tid in
      let>? () = Db.Produce.nft_ownership_event dbh c tid account () in
      if List.exists (fun (c0, tid0) -> c0 = c && tid0 = tid) acc then Lwt.return_ok acc
      else
        begin
          let>? () = Db.Produce.nft_item_event dbh c tid () in
          Lwt.return_ok @@ (c, tid) :: acc
        end
    ) [] (List.filter_map (fun x -> x) l)

let specs = [
  "--node", Arg.String (fun s -> Node.set_node s), "set node address";
  "--kafka-config", Arg.Set_string kafka_config_file, "set kafka configuration" ]

let () =
  Arg.parse specs (fun _ -> ()) "fix_bug_crawlori [options]";
  EzLwtSys.run (fun () -> Lwt.map (Result.iter_error Crawlori.Rp.print_error) (main ()))
