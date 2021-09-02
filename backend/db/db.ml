open Let
open Tzfunc.Proto

module PG = EzPG_rp.Make(struct type err = Crp.error let from_exn exn = `pg_exn exn end)
module PGOCaml = PG.PGOCaml

let () = PG.Pool.init ~database:Cconfig.database ()

let use dbh f = match dbh with
  | None -> PG.Pool.use f
  | Some dbh -> f dbh

let get_contracts ?dbh () =
  use dbh @@ fun dbh ->
  [%pgsql dbh "select address from contracts where main"]

let get_balance ?dbh ~contract ~owner token_id =
  use dbh @@ fun dbh ->
  let|>? l =
    [%pgsql dbh
        "select amount from tokens where contract = $contract and \
         owner = $owner and token_id = $token_id"] in
  match l with
  | [ amount ] -> Some amount
  | _ -> None

let set_origination _config _op _ori =
  (* TODO: insert contracs and set config *)
  Lwt.return_ok ()

let set_transaction _op _tr =
  (* TODO: insert tokens if mint, contract_updates for mint or burn and token_updates for transfer *)
  Lwt.return_ok ()

let set_operation _config op =
  let open Crawlori.Hooks in
  match op.bo_op.kind with
  | Transaction tr -> set_transaction op tr
  | Origination ori -> set_origination _config op ori
  | _ -> Lwt.return_ok ()

let set_main _config {Crawlori.Hooks.m_main; m_hash} =
  use None @@ fun dbh ->
  let>? () = [%pgsql dbh "update contracts set main = $m_main where block = $m_hash"] in
  let>? () = [%pgsql dbh "update tokens set main = $m_main where block = $m_hash"] in
  let>? () = [%pgsql dbh "update accounts set main = $m_main where block = $m_hash"] in
  let>? () = [%pgsql dbh "update token_updates set main = $m_main where block = $m_hash"] in
  let>? () = [%pgsql dbh "update contract_updates set main = $m_main where block = $m_hash"] in
  (* TODO: update the contracts, tokens, accounts and config from token_updates and token_contracts *)
  Lwt.return_ok ()
