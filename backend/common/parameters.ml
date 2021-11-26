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

let parse_update_operators m =
  match Typed_mich.parse_value Contract_spec.update_operators_entry m with
  | Ok (`seq l) ->
    Ok (Operator_updates (
        List.filter_map (function
            | `left (`tuple [ `address op_owner; `address op_operator; `nat op_token_id]) ->
              Some {op_owner; op_operator; op_token_id; op_add=true}
            | `right (`tuple [ `address op_owner; `address op_operator; `nat op_token_id]) ->
              Some {op_owner; op_operator; op_token_id; op_add=false}
            | _ -> None) l))
  | _ -> unexpected_michelson

let parse_update_operators_all m =
  match Typed_mich.parse_value Contract_spec.update_operators_all_entry m with
  | Ok (`seq l) ->
    Ok (Operator_updates_all (
        List.filter_map (function
            | `left (`address operator) -> Some (operator, true)
            | `right (`address operator) -> Some (operator, false)
            | _ -> None) l))
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

let parse_mint m =
  match Typed_mich.parse_value Contract_spec.mint_mt_entry m with
  | Ok (`tuple [`nat fa2m_token_id; `address fa2m_owner; `nat fa2m_amount;
                `assoc meta; `seq _royalties]) ->
    let fa2m_metadata = List.filter_map (function
        | (`string k, `string v) ->
          begin
            match Uutf.decode (Uutf.decoder ~encoding:`UTF_8 (`String v)) with
            | `Malformed _ -> None
            | _ -> Some (k, v)
          end
        | _ -> None) meta in
    Ok (Mint_tokens
          (MTMint { fa2m_token_id ; fa2m_owner ; fa2m_amount ; fa2m_metadata }))
  | _ ->
    match Typed_mich.parse_value Contract_spec.mint_nft_entry m with
    | Ok (`tuple [`nat fa2m_token_id; `address fa2m_owner; `assoc meta; `seq _royalties]) ->
      let fa2m_metadata = List.filter_map (function
          | (`string k, `string v) ->
          begin
            match Uutf.decode (Uutf.decoder ~encoding:`UTF_8 (`String v)) with
            | `Malformed _ -> None
            | _ -> Some (k, v)
          end
          | _ -> None) meta in
      Ok (Mint_tokens
            (NFTMint
               { fa2m_token_id ; fa2m_owner ; fa2m_amount = () ; fa2m_metadata }))
    | _ ->
      match Typed_mich.parse_value Contract_spec.mint_ubi_entry m with
      | Ok (`tuple [ `address ubim_owner; `nat ubim_token_id ]) ->
        let ubim_uri = Some "" in
        Ok (Mint_tokens (UbiMint { ubim_owner ; ubim_token_id ; ubim_uri }))
    | _ ->
      match Typed_mich.parse_value Contract_spec.mint_ubi2_entry m with
      | Ok (`tuple [ `tuple [ `address ubi2m_owner; `nat ubi2m_amount ]; `assoc meta; `nat ubi2m_token_id ]) ->
        let ubi2m_metadata =  List.filter_map (function
            | (`string k, `bytes v) ->
              let s = (Tzfunc.Crypto.hex_to_raw v :> string) in
              if decode s then Some (k, s)
              else None
            | _ -> None) meta in
        Ok (Mint_tokens
              (UbiMint2 { ubi2m_owner ; ubi2m_amount ; ubi2m_token_id ; ubi2m_metadata }))
      | _ -> unexpected_michelson

let parse_burn m =
  match Typed_mich.parse_value Contract_spec.burn_mt_entry m with
  | Ok (`tuple [ `nat token_id; `nat amount ]) ->
    Ok (Burn_tokens (MTBurn { token_id; amount }))
  | _ -> match Typed_mich.parse_value Contract_spec.burn_nft_entry m with
    | Ok (`nat id) -> Ok (Burn_tokens (NFTBurn id))
    | _ -> unexpected_michelson

let parse_metadata_uri = function
  | Mbytes h -> Ok (Metadata_uri (Tzfunc.Crypto.hex_to_raw h :> string))
  | _ -> unexpected_michelson

let parse_token_metadata m =
  match Typed_mich.parse_value Contract_spec.set_token_metadata_entry m with
  | Ok (`tuple [ `nat id; `assoc l ]) ->
    let l = List.filter_map (function
        | (`string k, `bytes v) ->
          Some (k, (Tzfunc.Crypto.hex_to_raw v :> string))
        | (`string k, `string v) ->
          Some (k, v)
        | _ -> None) l in
    Ok (Token_metadata (id, l))
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
  | EPnamed "update_operators", m -> parse_update_operators m
  | EPnamed "update_operators_for_all", m -> parse_update_operators_all m
  | EPnamed "transfer", m -> parse_transfer m
  | EPnamed "mint", m -> parse_mint m
  | EPnamed "burn", m -> parse_burn m
  | EPnamed "setMetadataUri", m -> parse_metadata_uri m
  | EPnamed "setTokenMetadata", m -> parse_token_metadata m
  | EPnamed "addMinter", m -> parse_add_minter m
  | EPnamed "removeMinter", m -> parse_remove_minter m
  | EPnamed "setTokenUriPattern", m -> parse_set_token_uri_pattern m
  | _ -> unexpected_michelson

let parse_set_royalties m =
  match Typed_mich.parse_value Contract_spec.set_royalties_entry m with
  | Ok (`tuple [ `address roy_contract; `nat id; `assoc l ]) ->
    let roy_royalties =
      List.filter_map (function
          | (`address account, `nat value) -> Some (account, value)
          | _ -> None) l in
    Ok {roy_contract; roy_token_id = Z.to_string id; roy_royalties}
  | _ -> unexpected_michelson

let parse_royalties e p =
  match e, p with
  | EPnamed "setRoyalties", m -> parse_set_royalties m
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
        Tzfunc.Read.unpack (Forge.prim `address) (Tzfunc.Crypto.hex_to_raw h) with
    | Ok (Mstring contract) -> Ok (ATFT {contract; token_id=None})
    | _ -> unexpected_michelson
    end
  | `right (`right (`left (`int z))), `bytes h ->
    begin match
        Tzfunc.Read.unpack (Forge.prim `pair ~args:[ Forge.prim `address; Forge.prim `nat ])
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

let parse_cancel m =
  match Typed_mich.(parse_value order_type m) with
  | Ok (`tuple [
      maker;
      `tuple [ `tuple [ make_asset_class; make_asset_data ]; _ ];
      _;
      `tuple [ `tuple [ take_asset_class; take_asset_data ]; _ ];
      `nat salt; _; _; _; _ ]) ->
    let$ maker = match maker with
      | `none -> Ok None
      | `some (`key maker) -> Ok (Some maker)
      | _ -> unexpected_michelson in
    let$ mat = parse_asset_type make_asset_class make_asset_data in
    let$ tat = parse_asset_type take_asset_class take_asset_data in
    let$ hash = Utils.hash_key maker mat tat salt in
    Ok (Cancel hash)
  | _ -> unexpected_michelson


let parse_do_transfers m =
  match Typed_mich.(parse_value do_transfers_type m) with
  | Ok (`tuple [
      _make_asset_type; _take_asset_type;
      _order_data_left; _order_data_right;
      `tuple [ `nat fill_make_value; `nat fill_take_value ];
      `tuple [
        left_maker;
        `tuple [ `tuple [ left_m_asset_class; left_m_asset_data ]; `nat left_m_asset_value ];
        _left_taker;
        `tuple [ `tuple [ left_t_asset_class; left_t_asset_data ]; _ ];
        `nat left_salt; _; _; _; _ ];
      `tuple [
        right_maker;
        `tuple [ `tuple [ right_m_asset_class; right_m_asset_data ]; `nat right_m_asset_value ];
        _right_taker;
        `tuple [ `tuple [ right_t_asset_class; right_t_asset_data ]; _ ];
        `nat right_salt; _; _; _; _ ];
      _fee_side; _royalties ]) ->
    let$ left_maker_edpk = parse_option_key left_maker in
    let left_maker = Option.map pk_to_pkh_exn left_maker_edpk in
    let$ left_mat = parse_asset_type left_m_asset_class left_m_asset_data in
    let$ left_tat = parse_asset_type left_t_asset_class left_t_asset_data in
    let$ left = Utils.hash_key left_maker_edpk left_mat left_tat left_salt in
    let left_asset = { asset_type = left_mat ; asset_value = left_m_asset_value } in
    let$ right_maker_edpk = parse_option_key right_maker in
    let right_maker = Option.map pk_to_pkh_exn right_maker_edpk in
    let$ right_mat = parse_asset_type right_m_asset_class right_m_asset_data in
    let$ right_tat = parse_asset_type right_t_asset_class right_t_asset_data in
    let$ right = Utils.hash_key right_maker_edpk right_mat right_tat right_salt in
    let right_asset = { asset_type = right_mat ; asset_value = right_m_asset_value } in
    Ok (DoTransfers
          {left; left_maker; left_asset; left_salt;
           right; right_maker; right_asset; right_salt;
           fill_make_value; fill_take_value})
  | _ -> unexpected_michelson

let parse_exchange e p =
  match e, p with
  | EPnamed "cancel", m -> parse_cancel m
  | EPnamed "doTransfers", m -> parse_do_transfers m
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
