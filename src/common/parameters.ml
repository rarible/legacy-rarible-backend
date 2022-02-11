open Proto
open Rtypes
open Utils
open Let

let parse_address = function
  | Mstring s -> Ok s
  | Mbytes h ->
    Result.map fst
      Tzfunc.Binary.Reader.(contract {s = Tzfunc.Crypto.hex_to_raw h; offset = 0})
  | _ -> unexpected_michelson

let parse_transfer m =
  match Typed_mich.parse_value Contract_spec.transfer_entry m with
  | Ok (`seq l) ->
    Ok (Transfers (
        List.filter_map (function
            | `tuple [ `address tr_source; `seq l ] ->
              let tr_txs = List.filter_map (function
                  | `tuple [ `address tr_destination; `nat tr_token_id; `nat tr_amount ] ->
                    Some {tr_destination; tr_token_id; tr_amount}
                  | _ -> None) l in
              Some {tr_source; tr_txs}
            | _ -> None) l))
  | _ -> unexpected_michelson

let decode s =
  let decoder = Uutf.decoder ~encoding:`UTF_8 (`String s) in
  let rec aux decoder =
    match Uutf.decode decoder with
    | `Uchar c when c <> Uchar.of_int 0 -> aux decoder
    | `Uchar _ -> false
    | `End -> true
    | `Malformed _ -> false
    | `Await -> false in
  aux decoder

let parse_attributes (l : micheline list) : Json_repr.ezjsonm option =
  let rec aux acc = function
    | [] -> Some (List.rev acc)
    | Mprim {prim=`Elt; args=[ Mstring k; Mprim {prim=`Pair; args=[fmt; v]; _} ]; _} :: q ->
      let fmt = match fmt with
        | Mprim {prim=`Some; args=[Mstring fmt]; _} -> [ "type", `String fmt ]
        | _ -> [] in
      let value_s = match v with
        | Mstring s -> Some s
        | Mbytes h ->
          let b = Tzfunc.Crypto.hex_to_raw h in
          if decode (b:> string) then Some (b :> string)
          else Some (h :> string)
        | _ -> None in
      begin match value_s with
        | None -> None
        | Some s ->
          let value =
            try EzEncoding.destruct Json_encoding.any_ezjson_value s
            with _ -> `String s in
          aux ((`O (("name", `String k) :: ("value", value) :: fmt)) :: acc) q
      end
    | _ -> None in
  Option.map (fun l -> `A l) @@ aux [] l

let get_string_bytes ?key (h : hex) : Json_repr.ezjsonm option =
  let b = Tzfunc.Crypto.hex_to_raw h in
  try match Tzfunc.Read.(unpack ~typ:(prim `string) b), key with
    | Ok (Mstring ""), Some "attributes" -> Some (`A []) (* dogami attributes *)
    | Ok (Mstring s), _ -> (* packed string *)
      if decode s then Some (`String s) else None

    | Ok (Mseq l), Some "attributes" -> (* dogami attributes *)
      parse_attributes l
    | _ ->
      let s = (b :> string) in
      if decode s then Some (try Ezjsonm.value_from_string s with _ -> `String s) else None
  with _ ->
    let s = (b :> string) in
    if decode s then Some (try Ezjsonm.value_from_string s with _ -> `String s) else None

let parse_metadata l =
  List.filter_map (function
      | (`string key, `bytes v) -> Option.map (fun s -> key, s) @@ get_string_bytes ~key v
      | _ -> None) l

let parse_royalties l =
  List.filter_map (function
      | `tuple [`address part_account; `nat value] ->
        begin
          try Some { part_account; part_value = Z.to_int32 value }
          with _ -> None
        end
      | _ -> None) l

let parse_mint m =
  match Typed_mich.parse_value Contract_spec.mint_mt_entry m with
  | Ok (`tuple [`nat fa2m_token_id; `address fa2m_owner; `nat fa2m_amount;
                `assoc meta; `seq royalties]) ->
    let fa2m_metadata = parse_metadata meta in
    let fa2m_royalties =  parse_royalties royalties in
    Ok (Mint_tokens
          (MTMint { fa2m_token_id ; fa2m_owner ; fa2m_amount ; fa2m_metadata; fa2m_royalties }))
  | _ ->
    match Typed_mich.parse_value Contract_spec.mint_nft_entry m with
    | Ok (`tuple [`nat fa2m_token_id; `address fa2m_owner; `assoc meta; `seq royalties]) ->
      let fa2m_metadata = parse_metadata meta in
      let fa2m_royalties = parse_royalties royalties in
      Ok (Mint_tokens
            (NFTMint
               { fa2m_token_id ; fa2m_owner ; fa2m_amount = () ; fa2m_metadata; fa2m_royalties }))
    | _ ->
      match Typed_mich.parse_value Contract_spec.mint_ubi_entry m with
      | Ok (`tuple [ `address ubim_owner; `nat ubim_token_id ]) ->
        let ubim_uri = Some "" in
        Ok (Mint_tokens (UbiMint { ubim_owner ; ubim_token_id ; ubim_uri }))
      | _ ->
        match Typed_mich.parse_value Contract_spec.mint_ubi2_entry m with
        | Ok (`tuple [ `tuple [ `address ubi2m_owner; `nat ubi2m_amount ]; `assoc meta; `nat ubi2m_token_id ]) ->
          let ubi2m_metadata = parse_metadata meta in
          Ok (Mint_tokens
                (UbiMint2 { ubi2m_owner ; ubi2m_amount ; ubi2m_token_id ; ubi2m_metadata }))

        | _ ->
          match Typed_mich.parse_value Contract_spec.mint_hen_entry m with
          | Ok (`tuple [
              `tuple [ `address fa2m_owner; `nat fa2m_amount ] ;
              `tuple [ `nat fa2m_token_id ; `assoc meta ] ]) ->
            let fa2m_metadata = parse_metadata meta in
            Ok (Mint_tokens
                  (HENMint { fa2m_token_id ; fa2m_owner ; fa2m_amount ; fa2m_metadata; fa2m_royalties = [] }))
          | _ -> unexpected_michelson

let parse_burn m =
  match Typed_mich.parse_value Contract_spec.burn_mt_entry m with
  | Ok (`tuple [ `nat token_id; `nat amount ]) ->
    Ok (Burn_tokens (MTBurn { token_id; amount }))
  | _ -> match Typed_mich.parse_value Contract_spec.burn_nft_entry m with
    | Ok (`nat id) -> Ok (Burn_tokens (NFTBurn id))
    | _ -> unexpected_michelson

let parse_metadata_uri m =
  match Typed_mich.parse_value (`tuple [`string; `bytes]) m with
  | Ok (`tuple [ `string key; `bytes h ]) ->
    Option.fold ~none:unexpected_michelson ~some:(fun s -> Ok (Metadata (key, s))) @@
    get_string_bytes ~key h
  | _ -> unexpected_michelson

let parse_add_minter m =
  match Typed_mich.parse_value `address m with
  | Ok (`address a) -> Ok (Add_minter a)
  | _ -> unexpected_michelson

let parse_remove_minter m =
  match Typed_mich.parse_value `address m with
  | Ok (`address a) -> Ok (Remove_minter a)
  | _ -> unexpected_michelson

let parse_set_token_uri_pattern m =
  match Typed_mich.parse_value `string m with
  | Ok (`string s) -> Ok (Token_uri_pattern s)
  | _ -> unexpected_michelson

let parse_fa2 e p =
  match e, p with
  | EPnamed "transfer", m -> parse_transfer m
  | EPnamed "mint", m -> parse_mint m
  | EPnamed "burn", m -> parse_burn m
  | EPnamed "set_metadata", m -> parse_metadata_uri m
  | EPnamed "add_minter", m -> parse_add_minter m
  | EPnamed "remove_minter", m -> parse_remove_minter m
  | EPnamed "set_token_metadata_uri", m -> parse_set_token_uri_pattern m
  | _ -> unexpected_michelson

let parse_set_royalties m =
  match Typed_mich.parse_value Contract_spec.set_royalties_entry m with
  | Ok (`tuple [ `address roy_contract; token_id; `seq l ]) ->
    let$ roy_token_id = match token_id with
      | `some (`nat id) -> Ok (Some id)
      | `none -> Ok None
      | _ -> unexpected_michelson in
    let roy_royalties = parse_royalties l in
    Ok {roy_contract; roy_token_id; roy_royalties}
  | _ -> unexpected_michelson

let parse_royalties e p =
  match e, p with
  | EPnamed "set_royalties", m -> parse_set_royalties m
  | _ -> unexpected_michelson

let parse_option_key : micheline_value -> (string option, _) result = function
  | `none -> Ok None
  | `some (`key maker) -> Ok (Some maker)
  | _ -> unexpected_michelson

let parse_asset_type (mclass : micheline_value) (mdata : micheline_value) =
 match mclass, mdata with
  | `left `unit, _ -> Ok ATXTZ
  | `right (`left `unit), `bytes h ->
    begin match
        Tzfunc.Read.unpack ~typ:(Forge.prim `address) (Tzfunc.Crypto.hex_to_raw h) with
    | Ok (Mstring contract) -> Ok (ATFT {contract; token_id=None})
    | _ -> unexpected_michelson
    end
  | `right (`right (`left (`int z))), `bytes h ->
    begin match
        Tzfunc.Read.unpack ~typ:(Forge.prim `pair ~args:[ Forge.prim `address; Forge.prim `nat ])
          (Tzfunc.Crypto.hex_to_raw h) with
    | Ok (Mprim { prim = `Pair; args = [ Mstring asset_contract; Mint asset_token_id ]; _}) ->
      if z = Z.zero then
        Ok (ATFT {contract=asset_contract; token_id = Some asset_token_id})
      else if z = Z.one then
        Ok (ATNFT {asset_contract; asset_token_id})
      else unexpected_michelson
    | _ -> unexpected_michelson
    end
  | _ -> unexpected_michelson

let parse_cancel e m =
  match e, Typed_mich.(parse_value order_type m) with
  | EPnamed "cancel", Ok (`tuple [
      maker;
      `tuple [ `tuple [ make_asset_class; make_asset_data ]; `nat m_asset_value ];
      _;
      `tuple [ `tuple [ take_asset_class; take_asset_data ]; `nat t_asset_value ];
      `nat cc_salt; _; _; _; _ ]) ->
    let$ cc_maker_edpk = parse_option_key maker in
    let$ mat = parse_asset_type make_asset_class make_asset_data in
    let$ tat = parse_asset_type take_asset_class take_asset_data in
    let cc_make = { asset_type = mat ; asset_value = m_asset_value } in
    let cc_take = { asset_type = tat ; asset_value = t_asset_value } in
    let$ cc_hash = Utils.hash_key cc_maker_edpk mat tat cc_salt in
    let cc_maker = Option.map pk_to_pkh_exn cc_maker_edpk in
    Ok { cc_hash ; cc_maker_edpk; cc_maker ; cc_make ; cc_take ; cc_salt}
  | _ -> unexpected_michelson

let parse_do_transfers e m =
  match e, Typed_mich.(parse_value do_transfers_type m) with
  | EPnamed "do_transfers", Ok (`tuple [
      `tuple [
        left_maker;
        `tuple [ `tuple [ left_m_asset_class; left_m_asset_data ]; `nat left_m_asset_value ];
        _left_taker;
        `tuple [ `tuple [ left_t_asset_class; left_t_asset_data ]; `nat left_t_asset_value ];
        `nat dt_left_salt; _; _; _; _ ];
      `tuple [
        right_maker;
        `tuple [ `tuple [ right_m_asset_class; right_m_asset_data ]; `nat right_m_asset_value ];
        _right_taker;
        `tuple [ `tuple [ right_t_asset_class; right_t_asset_data ]; `nat right_t_asset_value ];
        `nat dt_right_salt; _; _; _; _ ];
      _make_asset_type; _take_asset_type;
      _order_data_left; _order_data_right;
      `tuple [ `nat dt_fill_make_value; `nat dt_fill_take_value ];
      _fee_side; _royalties ]) ->
    let$ dt_left_maker_edpk = parse_option_key left_maker in
    let dt_left_maker = Option.map pk_to_pkh_exn dt_left_maker_edpk in
    let$ left_mat = parse_asset_type left_m_asset_class left_m_asset_data in
    let$ left_tat = parse_asset_type left_t_asset_class left_t_asset_data in
    let$ dt_left = Utils.hash_key dt_left_maker_edpk left_mat left_tat dt_left_salt in
    let dt_left_make_asset = { asset_type = left_mat ; asset_value = left_m_asset_value } in
    let dt_left_take_asset = { asset_type = left_tat ; asset_value = left_t_asset_value } in
    let$ dt_right_maker_edpk = parse_option_key right_maker in
    let dt_right_maker = Option.map pk_to_pkh_exn dt_right_maker_edpk in
    let$ right_mat = parse_asset_type right_m_asset_class right_m_asset_data in
    let$ right_tat = parse_asset_type right_t_asset_class right_t_asset_data in
    let$ dt_right = Utils.hash_key dt_right_maker_edpk right_mat right_tat dt_right_salt in
    let dt_right_make_asset = { asset_type = right_mat ; asset_value = right_m_asset_value } in
    let dt_right_take_asset = { asset_type = right_tat ; asset_value = right_t_asset_value } in
    Ok {dt_left; dt_left_maker_edpk; dt_left_maker; dt_left_make_asset;
        dt_left_take_asset; dt_left_salt; dt_right; dt_right_maker_edpk;
        dt_right_maker; dt_right_make_asset; dt_right_take_asset; dt_right_salt;
        dt_fill_make_value; dt_fill_take_value}
  | _ -> unexpected_michelson

let parse_ft_fa1_transfer m =
  match Typed_mich.parse_value (`tuple [ `address; `address; `nat ]) m with
  | Ok (`tuple [ `address tr_source; `address tr_destination; `nat tr_amount ]) ->
    Ok (FT_transfers [ {tr_source; tr_txs = [{tr_destination; tr_amount; tr_token_id = Z.zero}] } ])
  | _ -> unexpected_michelson

let parse_ft_fa2_transfer m =
  match parse_transfer m with
  | Ok (Transfers l) ->
    let filter trs =
      List.filter_map (fun tr ->
          let tr_txs = List.filter (fun tr -> tr.tr_token_id = Z.zero) tr.tr_txs in
          if tr_txs = [] then None else Some {tr with tr_txs}) trs in
    Ok (FT_transfers (filter l))
  | _ -> unexpected_michelson

let parse_ft_mint m =
  match Typed_mich.parse_value (`tuple [ `address; `nat; `nat ]) m with
  | Ok (`tuple [ `address owner; `nat amount; `nat id ]) ->
    if id = Z.zero then
      Ok (FT_mint { owner; amount })
    else unexpected_michelson
  | _ -> unexpected_michelson

let parse_ft_burn m =
  match Typed_mich.parse_value (`tuple [ `address; `nat; `nat ]) m with
  | Ok (`tuple [ `address owner; `nat amount; `nat id ]) ->
    if id = Z.zero then
      Ok (FT_burn { owner; amount })
    else unexpected_michelson
  | _ -> unexpected_michelson

let parse_ft_fa1 e p =
  match e, p with
  | EPnamed "transfer", m -> parse_ft_fa1_transfer m
  | EPnamed "mint", m -> parse_ft_mint m
  | EPnamed "burn", m -> parse_ft_burn m
  | _ -> unexpected_michelson

let parse_ft_fa2 e p =
  match e, p with
  | EPnamed "transfer", m -> parse_ft_fa2_transfer m
  | EPnamed "mint", m -> parse_ft_mint m
  | EPnamed "burn", m -> parse_ft_burn m
  | _ -> unexpected_michelson

let parse_process_transfer_lugh m =
  match Typed_mich.parse_value (`tuple [ `tuple [`nat; `address];  `nat; `address; `nat ]) m with
  | Ok (`tuple [ `tuple [`nat tr_amount; `address tr_source]; `nat fees;
                 `address tr_destination; `nat id ]) ->
    if id = Z.zero  then
      Ok (FT_transfers [
          { tr_source; tr_txs = [
                {tr_token_id = Z.zero; tr_amount; tr_destination};
                {tr_token_id = Z.zero; tr_amount = fees; tr_destination = ""}
              ]
          }
        ])
    else unexpected_michelson
  | _ -> unexpected_michelson

let parse_ft_lugh e m =
  match e with
  | EPnamed "process_transfer" -> parse_process_transfer_lugh m
  | EPnamed "mint" -> parse_ft_mint m
  | EPnamed "burn" -> parse_ft_burn m
  | _ -> unexpected_michelson
