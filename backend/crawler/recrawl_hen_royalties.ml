open Crawlori
open Make(Pg)(struct type extra = Rtypes.config end)
open Proto
open Let
open Rtypes

let filename = ref None
let node = ref "https://tz.functori.com"
let step = ref 10000L

let spec = [
  "--node", Arg.Set_string node, "Node to use";
  "--step", Arg.Int (fun i -> step := Int64.of_int i), "Steps";
]

let update_royalties ?dbh ~node ~id ~contract token_id =
  let> r = Tzfunc.Node.get_bigmap_value ~base:(EzAPI.BASE node) ~typ:(Tzfunc.Node.prim `nat)
      id (Mint token_id) in
  match r with
  | Error e ->
    Format.eprintf "%s@." (Tzfunc.Rp.string_of_error e);
    Lwt.return_ok ()
  | Ok (Some (Micheline (Mprim {prim = `Pair; args = [Mstring account; Mint value]; _}))) ->
    Db.Utils.update_hen_royalties ?dbh ~contract ~token_id ~account ~value ()
  | _ ->
    Format.eprintf "return type not understood@.";
    Lwt.return_ok ()


let main () =
  Arg.parse spec (fun f -> filename := Some f) "recrawl_hen_royalties.exe [options] config.json";
  let>? config = Lwt.return @@ Crawler_config.get !filename Rtypes.config_enc in
  match config.Config.extra.hen_info with
  | Some info ->
    Db.Misc.use None (fun dbh ->
        let>? n = Db.Utils.hen_token_ids_count ~dbh info.hen_contract in
        let m = Int64.div n !step in
        iter_rp (fun i ->
            let offset = Int64.mul !step i in
            let>? token_ids = Db.Utils.hen_token_ids ~dbh ~offset ~limit:!step info.hen_contract in
            iter_rp (fun token_id ->
                update_royalties ~dbh ~node:!node ~id:info.hen_minter_id
                  ~contract:info.hen_contract token_id)
            @@ List.map Z.of_string token_ids)
        @@ List.init Int64.(to_int @@ succ m) Int64.of_int)
  | _ ->
    Format.printf "Missing 'hen_info' in config file@.";
    Lwt.return_ok ()

let () =
  EzLwtSys.run @@ fun () ->
  Lwt.map (function
      | Error e -> Rp.print_error e
      | Ok _ -> ()) (main ())
