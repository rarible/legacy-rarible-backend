open Let
open Tzfunc
open Node
open Proto

let node = ref "https://hangzhou.tz.functori.com"
let contract = ref None
let token_id = ref None
let owner = ref None
let number = ref None
let block = ref None

let spec = [
  "--contract", Arg.String (fun s -> contract := Some s),
  "Contract to check";
  "--node", Arg.Set_string node, "Node address";
  "--token_id", Arg.String (fun s -> token_id := Some (Z.of_string s)), "Token ID to check";
  "--owner", Arg.String (fun s -> owner := Some s), "Owner to check";
  "--block", Arg.String (fun s -> block := Some s), "Block at which to check";
  "--number", Arg.Int (fun i -> number := Some (Int64.of_int i)), "Number of token to check";
]

let expr ~typ value =
  match Forge.pack typ value with
  | Error _ -> None
  | Ok b ->
    Some Tzfunc.Crypto.(Base58.encode ~prefix:Prefix.script_expr_hash @@ Blake2b_32.hash [ b ])

let main () =
  let>? block = match !block with
    | Some b -> Lwt.return_ok b
    | None ->
      let|>? b, _ = Pg.head None in
      b in
  let>? l =
    Db.Utils.random_tokens ?contract:!contract ?token_id:!token_id ?owner:!owner
      ?number:!number () in
  iter_rp (fun r ->
      Format.printf "\027[0;36mCheck %s[%s] for %s (%s, %s)\027[0m@."
        (String.sub r#contract 0 10) r#token_id (String.sub r#owner 0 10) (Z.to_string r#amount)
        (Option.fold ~none:"None" ~some:Z.to_string r#balance);
      let ok, typ, value = match Option.map (EzEncoding.destruct Mtyped.stype_enc.json) r#ledger_key with
        | Some (`tuple [ `address; `nat ]) ->
          true, prim `pair ~args:[ prim `address; prim `nat ],
          prim `Pair ~args:[ Mstring r#owner; Mint (Z.of_string r#token_id) ]
        | Some (`tuple [ `nat; `address ]) ->
          true, prim `pair ~args:[ prim `nat; prim `address ],
          prim `Pair ~args:[ Mint (Z.of_string r#token_id); Mstring r#owner ]
        | Some `nat -> true, prim `nat, Mint (Z.of_string r#token_id)
        | _ -> false, prim `unit, prim `Unit in
      if not ok then (
        Format.printf "\027[0;33mLedger type unknown\027[0m@.";
        Lwt.return_ok ())
      else
        let> v = Node.get_bigmap_value ~block ~typ ~base:(EzAPI.BASE !node)
            (Z.of_string r#ledger_id) value in
        match Option.map (EzEncoding.destruct Mtyped.stype_enc.json) r#ledger_value, v with
        | Some `nat, Ok (Some (Mint z)) ->
          if z = r#amount then Format.printf "\027[0;32mOk\027[0m@."
          else Format.printf "\027[0;31mWrong %s %s\027[0m@." (Z.to_string r#amount) (Z.to_string z);
          Lwt.return_ok ()
        | Some `address, Ok (Some (Mstring s)) ->
          if r#amount = Z.zero && s <> r#owner then Format.printf "\027[0;32mOk\027[0m@."
          else if r#amount = Z.one && s = r#owner then Format.printf "\027[0;32mOk\027[0m@."
          else Format.printf "\027[0;31mWrong %s\027[0m@." s;
          Lwt.return_ok ()
        | Some `nat, _ ->
          if r#amount = Z.zero then Format.printf "\027[0;32mOk\027[0m@."
          else Format.printf "\027[0;31mWrong\027[0m@.";
          Lwt.return_ok ()
        | Some `address, _ ->
          if r#amount = Z.zero then Format.printf "\027[0;32mOk\027[0m@."
          else Format.printf "\027[0;31mWrong\027[0m@.";
          Lwt.return_ok ()
        | _ -> Lwt.return_ok ()
    ) l


let () =
  Arg.parse spec (fun _ -> ()) "check_ledger";
  Lwt_main.run @@
  Lwt.map (function
      | Error e ->
        Format.eprintf "%s@." (Crawlori.Rp.string_of_error e);
        exit 1
      | Ok () -> ()) @@
  main ()
