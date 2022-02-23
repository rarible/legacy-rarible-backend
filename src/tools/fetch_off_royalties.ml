open Let
open Tzfunc
open Proto
open Rtypes
open Db.Misc

let collection = ref ""
let issuer = ref ""
let node = ref "https://tz.functori.com"
let bigmap = ref Z.zero
let issuer_bigmap = ref Z.zero
let kind = ref ""
let step = ref 10000L

let spec = [
  "--issuer", Arg.Set_string issuer, "set fxhash issuer";
  "--issuer-bigmap", Arg.String (fun s -> issuer_bigmap := Z.of_string s), "set fxhash issuer bigmap";
  "--collection", Arg.Set_string collection, "set collection";
  "--collection-bigmap", Arg.String (fun s -> bigmap := Z.of_string s), "set bigmap";
  "--kind", Arg.Set_string kind, "kind of royalties (versum, fxhash, hen, one_of, rarible)";
  "--node", Arg.Set_string node, "tezos node to use";
  "--step", Arg.Int (fun i -> step := Int64.of_int i), "steps";
]

let update_royalties id royalties =
  use None @@ fun dbh ->
  [%pgsql dbh
      "update token_info set royalties = $royalties where \
       contract = ${!collection} and token_id = $id"]

let print_result r =
  begin match r with
    | Error e -> Rp.print_error e
    | Ok _ -> ()
  end;
  None

let iter_ids f =
  let>? n = Db.Utils.collection_items_count !collection in
  let m = Int64.div n !step in
  iter_rp (fun i ->
      let offset = Int64.mul !step i in
      let>? ids = Db.Utils.collection_items ~offset ~limit:!step !collection in
      iter_rp (fun id ->
          Format.printf "%s %s@." !collection id;
          let> o = f id in
          match o with
          | None -> Lwt.return_ok ()
          | Some royalties -> update_royalties id royalties) ids) @@
  List.init Int64.(to_int @@ succ m) Int64.of_int

let get_hen id =
  let|> r = Node.(get_bigmap_value ~typ:(prim `nat) !bigmap (Mint (Z.of_string id))) in
  match r with
  | Ok (Some (Mprim {prim = `Pair; args = [Mstring part_account; Mint v]; _})) ->
    Some (
      EzEncoding.construct parts_enc [ {
          part_account; part_value = Z.(to_int32 @@ v * ~$10) } ])
  | r -> print_result r

let get_rarible id =
  let|> r = Node.(get_bigmap_value ~typ:(prim `nat) !bigmap (Mint (Z.of_string id))) in
  match r with
  | Ok (Some (Mseq l)) ->
    let l = List.filter_map (function
        | Mprim {prim = `Pair; args = [Mstring part_account; Mint v]; _} ->
          Some { part_account; part_value = Z.to_int32 v }
        | _ -> None) l in
    Some (EzEncoding.construct parts_enc l)
  | r -> print_result r

let get_versum id =
  let typ = Common.Contract_spec.versum_royalties_field.bmt_value in
  let|> r = Node.(get_bigmap_value ~typ:(prim `nat) !bigmap (Proto.Mint (Z.of_string id))) in
  match r with
  | Ok (Some m) ->
    begin match Mtyped.parse_value typ m with
      | Ok (`tuple [ _; _; _; `nat royalty; `seq l ]) ->
        let l = List.filter_map (function
            | `tuple [ `address part_account; `nat pct ] ->
              Some {
                part_account;
                part_value = Z.(to_int32 @@ royalty * pct / ~$100) }
            | _ -> None) l in
        Some (EzEncoding.construct parts_enc l)
      | r -> print_result r
    end
  | r -> print_result r

let get_fxhash id =
  if (!issuer="" || !issuer_bigmap = Z.zero) then (
    Format.printf "Missing issuer or issuer-bigmap or kind argument@.";
    exit 1)
  else
    let data_typ = Common.Contract_spec.fxhash_data_field.bmt_value in
    let issuer_typ = Common.Contract_spec.fxhash_issuer_field.bmt_value in
    let> r = Node.(get_bigmap_value ~typ:(prim `nat) !bigmap (Proto.Mint (Z.of_string id))) in
    match r with
    | Ok (Some m) ->
      begin match Mtyped.parse_value data_typ m with
        | Ok (`tuple [ `tuple [_; `nat issuer_id ]; _; _ ]) ->
          let|> r = Node.(get_bigmap_value ~typ:(prim `nat) !issuer_bigmap (Proto.Mint issuer_id)) in
          begin match r with
            | Ok (Some m) ->
              begin match Mtyped.parse_value issuer_typ m with
                | Ok (`tuple [`tuple [ `tuple [ `address part_account; _ ]; _; _; _ ]; _; `nat pct; _; _ ]) ->
                  Some (EzEncoding.construct parts_enc [ {
                      part_account; part_value = Z.(to_int32 @@ pct * ~$10) } ])
                | r -> print_result r
              end
            | r -> print_result r
          end
        | r -> Lwt.return @@ print_result r
      end
    | r -> Lwt.return @@ print_result r

let get_one_of =
  let l = [
    1, 1000000, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    100001, 200000, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    200001, 300000, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    300001, 400000, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    400001, 500000, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    500001, 600000, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    600001, 700000, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    700001, 800000, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    800001, 900000, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    900001, 915000, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    915001, 919500, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    919501, 949500, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    949501, 954000, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    954001, 969000, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    969001, 999000, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    999001, 1000000, "tz2TRbmJEEEEpweipjsENLzwGLfpJU3cQqQw";
    1057532, 1077531, "tz2Exn7aFPiaF4Ah2tCuexrYP5ZP1ECKKSk7";
    1077532, 1078531, "tz2Exn7aFPiaF4Ah2tCuexrYP5ZP1ECKKSk7";
    1078532, 1079331, "tz2Exn7aFPiaF4Ah2tCuexrYP5ZP1ECKKSk7";
    1079333, 1079632, "tz2Exn7aFPiaF4Ah2tCuexrYP5ZP1ECKKSk7";
    1079633, 1079882, "tz2Exn7aFPiaF4Ah2tCuexrYP5ZP1ECKKSk7";
    1079883, 1079892, "tz2Exn7aFPiaF4Ah2tCuexrYP5ZP1ECKKSk7";
    1026001, 1033000, "tz2PDz2xNVo9Ehtcd5iqiYRwL6RQd4qk72Sd";
    1033001, 1040000, "tz2PDz2xNVo9Ehtcd5iqiYRwL6RQd4qk72Sd";
    1040001, 1047000, "tz2PDz2xNVo9Ehtcd5iqiYRwL6RQd4qk72Sd";
    1047001, 1050000, "tz2PDz2xNVo9Ehtcd5iqiYRwL6RQd4qk72Sd";
    1050001, 1052000, "tz2PDz2xNVo9Ehtcd5iqiYRwL6RQd4qk72Sd";
    1052001, 1052020, "tz2PDz2xNVo9Ehtcd5iqiYRwL6RQd4qk72Sd";
    1079332, 1079332, "tz2PDz2xNVo9Ehtcd5iqiYRwL6RQd4qk72Sd";
    1052021, 1057531, "tz2RqGbjw67kHkFdCWkysjMkZVsNewg6pRhR";
    1144855, 1144954, "tz2RqGbjw67kHkFdCWkysjMkZVsNewg6pRhR";
    1150489, 1155488, "tz2RqGbjw67kHkFdCWkysjMkZVsNewg6pRhR";
    1155489, 1155496, "tz2RqGbjw67kHkFdCWkysjMkZVsNewg6pRhR";
    1155497, 1155738, "tz2RqGbjw67kHkFdCWkysjMkZVsNewg6pRhR";
    1079893, 1084892, "tz2Q4RjMtD2aKnkdJ97fgTvovbmQVVyg7ndE";
    1084893, 1094892, "tz2Q4RjMtD2aKnkdJ97fgTvovbmQVVyg7ndE";
    1094893, 1104892, "tz2Q4RjMtD2aKnkdJ97fgTvovbmQVVyg7ndE";
    1104893, 1114892, "tz2Q4RjMtD2aKnkdJ97fgTvovbmQVVyg7ndE";
    1114893, 1116892, "tz2Q4RjMtD2aKnkdJ97fgTvovbmQVVyg7ndE";
    1116893, 1120892, "tz2Q4RjMtD2aKnkdJ97fgTvovbmQVVyg7ndE";
    1120893, 1124892, "tz2Q4RjMtD2aKnkdJ97fgTvovbmQVVyg7ndE";
    1124893, 1128892, "tz2Q4RjMtD2aKnkdJ97fgTvovbmQVVyg7ndE";
    1128893, 1129192, "tz2Q4RjMtD2aKnkdJ97fgTvovbmQVVyg7ndE";
    1129193, 1129792, "tz2Q4RjMtD2aKnkdJ97fgTvovbmQVVyg7ndE";
    1129793, 1130392, "tz2Q4RjMtD2aKnkdJ97fgTvovbmQVVyg7ndE";
    1130393, 1130992, "tz2Q4RjMtD2aKnkdJ97fgTvovbmQVVyg7ndE";
    1146755, 1147254, "tz2TUBbniVpnST4jSpLGbrbGBomeFTaH27Lq";
    1147255, 1147754, "tz2TUBbniVpnST4jSpLGbrbGBomeFTaH27Lq";
    1147755, 1148254, "tz2TUBbniVpnST4jSpLGbrbGBomeFTaH27Lq";
    1148255, 1148354, "tz2TUBbniVpnST4jSpLGbrbGBomeFTaH27Lq";
    1148455, 1148554, "tz2TUBbniVpnST4jSpLGbrbGBomeFTaH27Lq";
    1148455, 1148554, "tz2TUBbniVpnST4jSpLGbrbGBomeFTaH27Lq";
    1148555, 1148555, "tz2TUBbniVpnST4jSpLGbrbGBomeFTaH27Lq";
    1149273, 1149322, "tz2TUBbniVpnST4jSpLGbrbGBomeFTaH27Lq";
    1149323, 1149372, "tz2TUBbniVpnST4jSpLGbrbGBomeFTaH27Lq";
    1149373, 1149422, "tz2TUBbniVpnST4jSpLGbrbGBomeFTaH27Lq";
    1149423, 1149441, "tz2TUBbniVpnST4jSpLGbrbGBomeFTaH27Lq";
    1130993, 1134325, "tz2BuzfuEULGzGuWcxc5skF8mVQJJc7KiaE8";
    1134326, 1134525, "tz2BuzfuEULGzGuWcxc5skF8mVQJJc7KiaE8";
    1134526, 1143499, "tz2BuzfuEULGzGuWcxc5skF8mVQJJc7KiaE8";
    1143500, 1144054, "tz2BuzfuEULGzGuWcxc5skF8mVQJJc7KiaE8";
    1144055, 1144387, "tz2BuzfuEULGzGuWcxc5skF8mVQJJc7KiaE8";
    1144388, 1144409, "tz2BuzfuEULGzGuWcxc5skF8mVQJJc7KiaE8";
    1144410, 1144410, "tz2BuzfuEULGzGuWcxc5skF8mVQJJc7KiaE8";
    1144411, 1144854, "tz2CG8EvFSCsghhTVchANGd35MdXx5KRA3cV";
    1144955, 1146754, "tz1cA42C9sFEHu6xjFKBiKH1fgqxLrVRAxvA";
    1148556, 1149255, "tz1cA42C9sFEHu6xjFKBiKH1fgqxLrVRAxvA";
    1149256, 1149272, "tz1cA42C9sFEHu6xjFKBiKH1fgqxLrVRAxvA";
    1150242, 1150242, "tz1cA42C9sFEHu6xjFKBiKH1fgqxLrVRAxvA";
    1149442, 1149641, "tz2P2w7puVb58ahsME3LbMVmkh98TVUr3zS7";
    1149642, 1149941, "tz2P2w7puVb58ahsME3LbMVmkh98TVUr3zS7";
    1149942, 1150241, "tz2P2w7puVb58ahsME3LbMVmkh98TVUr3zS7";
    1150243, 1150317, "tz2P2w7puVb58ahsME3LbMVmkh98TVUr3zS7";
    1150318, 1150392, "tz2P2w7puVb58ahsME3LbMVmkh98TVUr3zS7";
    1150393, 1150467, "tz2P2w7puVb58ahsME3LbMVmkh98TVUr3zS7";
    1150468, 1150477, "tz2P2w7puVb58ahsME3LbMVmkh98TVUr3zS7";
    1150478, 1150487, "tz2P2w7puVb58ahsME3LbMVmkh98TVUr3zS7";
    1150488, 1150488, "tz2P2w7puVb58ahsME3LbMVmkh98TVUr3zS7";
  ] in
  let rec aux id = function
    | (start, end_, account) :: _ when id >= start && id <= end_ -> Some account
    | _ :: q -> aux id q
    | [] -> None in
  fun id ->
    match aux (int_of_string id) l with
    | None -> Lwt.return_none
    | Some part_account ->
      Lwt.return_some @@
      EzEncoding.construct parts_enc [ { part_account; part_value = 1000l } ]

let () =
  Arg.parse spec (fun _ -> ()) "fetch_off_royalties.exe [OPTIONS]";
  Node.set_node !node;
  if !collection = "" || !bigmap = Z.zero || !kind = "" then (
    Format.printf "Missing collection or collection-bigmap or kind argument@.";
    exit 1);
  let main () =
    if !kind = "versum" then iter_ids get_versum
    else if !kind = "fxhash" then iter_ids get_fxhash
    else if !kind = "hen" then iter_ids get_hen
    else if !kind = "rarible" then iter_ids get_rarible
    else if !kind = "one_of" then iter_ids get_one_of
    else (
      Format.printf "Unknown kind %S@." !kind;
      exit 1) in
  Lwt_main.run (Lwt.map (Result.iter_error Crawlori.Rp.print_error) @@ main ())
