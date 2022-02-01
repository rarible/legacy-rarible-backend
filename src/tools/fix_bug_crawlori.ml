open Let
open Tzfunc
open Proto

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
  let>? (block, _) = Pg.head None in
  let>? l = Db.Utils.get_alt_token_balance_updates () in
  let>? l =
    map_rp (fun r ->
        match r#account, r#ledger_key, r#ledger_value with
        | Some account, Some key, Some value ->
          Format.printf "Handle %s %s %s@." r#contract r#token_id account;
          let> b = get_balance ~block ~ledger_id:(Z.of_string r#ledger_id) ~key
              ~value ~token_id:r#token_id ~account in
          begin match b with
            | Some b ->
              let>? () =
                Db.Utils.update_token ~contract:r#contract ~token_id:r#token_id ~account b in
              Lwt.return_ok @@ Some (r#contract, r#token_id, account)
            | _ -> Lwt.return_ok None
          end
        | _ -> Lwt.return_ok None) l in
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
  "--node", Arg.String (fun s -> Node.set_node s), "set node address" ]

let () =
  Arg.parse specs (fun _ -> ()) "fix_bug_crawlori [options]";
  EzLwtSys.run (fun () -> Lwt.map (Result.iter_error Crawlori.Rp.print_error) (main ()))
