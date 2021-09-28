open Proto
open Rtypes
open Utils

let (let$) = Result.bind

let unexpected_michelson = Error `unexpected_michelson_value

let parse_address = function
  | Mstring s -> Ok s
  | Mbytes h ->
    Result.map fst
      Tzfunc.Binary.Reader.(contract {s = Hex.to_string h; offset = 0})
  | _ -> unexpected_michelson

let parse_update_operators m =
  let rec aux acc = function
    | [] -> Ok acc
    | Mprim { prim = add; args = [
        Mprim { prim = `Pair; args = [ owner; operator; Mint id ]; _ }
      ]; _ } :: t ->
      let$ op_owner = parse_address owner in
      let$ op_operator = parse_address operator in
      begin match add with
        | `Left->
          aux ({op_owner; op_operator; op_token_id = Z.to_int64 id; op_add=true} :: acc) t
        | `Right ->
          aux ({op_owner; op_operator; op_token_id = Z.to_int64 id; op_add=false} :: acc) t
        | _ -> unexpected_michelson
      end
    | _ -> unexpected_michelson in
  match m with
  | Mseq l ->
    let$ l = aux [] l in
    Ok (Operator_updates (List.rev l))
  | _ -> unexpected_michelson

let parse_update_operators_all m =
  let rec aux acc = function
    | [] -> Ok acc
    | Mprim { prim = `Left; args = [ operator ]; _} :: t ->
      let$ operator = parse_address operator in
      aux ((operator, true) :: acc) t
    | Mprim { prim = `Right; args = [ operator ]; _} :: t ->
      let$ operator = parse_address operator in
      aux ((operator, false) :: acc) t
    | _ -> unexpected_michelson in
  match m with
  | Mseq l ->
    let$ l = aux [] l in
    Ok (Operator_updates_all (List.rev l))
  | _ -> unexpected_michelson

let parse_transfer m =
  let rec aux_to acc = function
    | [] -> Ok acc
    | Mprim { prim = `Pair; args = [
        destination;
        Mint id;
        Mint amount;
      ]; _} :: t ->
      let$ tr_destination = parse_address destination in
      aux_to ({tr_destination; tr_token_id = Z.to_int64 id; tr_amount = Z.to_int64 amount} :: acc) t
    | _ -> unexpected_michelson in
  let rec aux_from acc = function
    | [] -> Ok acc
    | Mprim { prim = `Pair; args = [
          source;
          Mseq txs
        ]; _} :: t ->
      let$ tr_source = parse_address source in
      let$ txs = aux_to [] txs in
      aux_from ({ tr_source; tr_txs = List.rev txs } :: acc) t
    | _ -> unexpected_michelson in
  match m with
  | Mseq l ->
    let$ l = aux_from [] l in
    Ok (Transfers (List.rev l))
  | _ -> unexpected_michelson

let parse_mint = function
  | Mprim { prim = `Pair; args = [
      Mint id;
      owner;
      Mint amount;
      Mseq royalties ]; _ } ->
    let mi_meta = [] in
    let$ tk_owner = parse_address owner in
    let mi_royalties = List.filter_map (function
        | Mprim { prim = `Elt; args = [ Mstring s; Mint i ]; _ } -> Some (s, Z.to_int64 i)
        | _ -> None) royalties in
    Ok (Mint_tokens {
        mi_op = { tk_op = { tk_token_id = Z.to_int64 id; tk_amount = Z.to_int64 amount };
                  tk_owner };
        mi_royalties; mi_meta })
  | _ -> unexpected_michelson

let parse_burn = function
  | Mprim {prim = `Pair; args = [Mint id; owner; Mint amount]; _ } ->
    let$ tk_owner = parse_address owner in
    Ok (Burn_tokens { tk_owner; tk_op = {
        tk_token_id = Z.to_int64 id; tk_amount = Z.to_int64 amount } })
  | _ -> unexpected_michelson

let parse_metadata_uri = function
  | Mbytes h -> Ok (Metadata_uri (Hex.to_string h))
  | _ -> unexpected_michelson

let parse_token_metadata = function
  | Mprim {prim = `Pair; args = [Mint id; Mseq l]; _ } ->
    let l = List.filter_map (function
        | Mprim { prim = `Elt; args = [ Mstring k; Mstring v ]; _ } ->
          Some (k, v)
        | _ -> None) l in
    Ok (Token_metadata (Z.to_int64 id, l))
  | _ -> unexpected_michelson

let rec parse_nft e p =
  let p = flatten p in
  match e, p with
  | EPdefault, Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_nft (EPnamed "left") m
  | EPdefault, Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_nft (EPnamed "right") m
  | EPnamed "left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_nft (EPnamed "left_left") m
  | EPnamed "left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_nft (EPnamed "left_right") m
  | EPnamed "right", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_nft (EPnamed "right_left") m
  | EPnamed "right", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_nft (EPnamed "right_right") m
  | EPnamed "left_left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_nft (EPnamed "balance_of") m
  | EPnamed "left_left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_nft (EPnamed "update_operators") m
  | EPnamed "left_right", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_nft (EPnamed "update_operators_for_all") m
  | EPnamed "left_right", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_nft (EPnamed "transfer") m
  | EPnamed "right_left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_nft (EPnamed "mint") m
  | EPnamed "right_left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_nft (EPnamed "burn") m
  | EPnamed "right_right", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_nft (EPnamed "setMetadaraUri") m
  | EPnamed "right_right", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_nft (EPnamed "setTokenMetadata") m

  | EPnamed "update_operators", m -> parse_update_operators m
  | EPnamed "update_operators_for_all", m -> parse_update_operators_all m
  | EPnamed "transfer", m -> parse_transfer m
  | EPnamed "mint", m -> parse_mint m
  | EPnamed "burn", m -> parse_burn m
  | EPnamed "setMetadataUri", m -> parse_metadata_uri m
  | EPnamed "setTokenMetadata", m -> parse_token_metadata m

  | _ -> unexpected_michelson

let parse_set_royalties m = match m with
  | Mprim { prim = `Pair; args = [
      contract; Mint id; Mseq l ]; _ } ->
    begin match parse_address contract with
      | Ok roy_contract ->
        let roy_royalties = List.filter_map (function
            | Mprim { prim = `Pair; args = [ account; Mint value ]; _ } ->
              begin match parse_address account with
                | Ok account -> Some (account, Z.to_int64 value)
                | _ -> None
              end
            | _ -> None) l in
        Ok {roy_contract; roy_token_id = Z.to_int64 id; roy_royalties}
      | _ -> unexpected_michelson
    end
  | _ -> unexpected_michelson

let rec parse_royalties e p =
  let p = flatten p in
  match e, p with
  | EPdefault, Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_royalties (EPnamed "left") m
  | EPdefault, Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_royalties (EPnamed "right") m
  | EPnamed "left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_royalties (EPnamed "getRoyalties") m
  | EPnamed "left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_royalties (EPnamed "transferOwnership") m
  | EPnamed "right", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_royalties (EPnamed "claimOwnership") m
  | EPnamed "right", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_royalties (EPnamed "setRoyalties") m
  | EPnamed "setRoyalties", m -> parse_set_royalties m
  | _ -> unexpected_michelson

let parse_edpk = function
  | Mstring s -> Ok s
  | Mbytes h ->
    Result.map fst
      Tzfunc.Binary.Reader.(pk {s = Hex.to_string h; offset = 0})
  | _ -> unexpected_michelson

let parse_option_key = function
  | Mprim { prim = `None; _ } -> Ok None
  | Mprim { prim = `Some; args = [ a ]; _} ->
    let$ edpk = parse_edpk a in
    Ok (Some edpk)
  | _ -> unexpected_michelson

let parse_asset_type mclass mdata = match mclass, mdata with
  | Mprim { prim = `Left; args = [ Mprim { prim = `Unit; _ } ]; _ }, _ -> Ok ATXTZ
  | Mprim { prim = `Right; args = [ Mprim { prim = `Left; args = [ Mprim { prim = `Unit; _} ]; _ } ]; _},
    Mbytes h ->
    begin match
        Tzfunc.Read.unpack (Forge.prim `address) (Hex.to_string h) with
    | Ok (Mstring a) -> Ok (ATFA_1_2 a)
    | _ -> unexpected_michelson
    end
  | Mprim { prim = `Right; args = [ Mprim { prim = `Right; args = [
      Mprim { prim = `Left; args = [ Mprim { prim = `Unit; _} ]; _ } ]; _} ]; _},
    Mbytes h ->
    begin match
        Tzfunc.Read.unpack (Forge.prim `pair ~args:[ Forge.prim `address; Forge.prim `nat ])
          (Hex.to_string h) with
    | Ok (Mprim { prim = `Pair; args = [ Mstring asset_fa2_contract; Mint token_id ]; _}) ->
      let asset_fa2_token_id = Z.to_string token_id in
      Ok (ATFA_2 {asset_fa2_contract; asset_fa2_token_id})
    | _ -> unexpected_michelson
    end
  | _ -> unexpected_michelson

let parse_option_tsp = function
  | Mprim { prim = `None; _ } -> Ok None
  | Mprim { prim = `Some; args = [ Mstring s ]; _ } ->
    Ok (Some (Proto.A.cal_of_str s))
  | Mprim { prim = `Some; args = [ Mint i ]; _ } ->
    Ok (Some (CalendarLib.Calendar.from_unixfloat @@ Z.to_float i))
  | _ -> unexpected_michelson

let parse_cancel = function
  | Mprim { prim = `Pair; args = [
      maker; make_asset_class; make_asset_data; _;
      _; take_asset_class; take_asset_data; _;
      Mint salt; _; _; _; _ ]; _ } ->
    let$ maker = parse_option_key maker in
    let$ mat = parse_asset_type make_asset_class make_asset_data in
    let$ tat = parse_asset_type take_asset_class take_asset_data in
    let salt = Z.to_string salt in
    let$ hash = Utils.hash_key maker mat tat salt in
    Ok (Cancel hash)
  | _ -> unexpected_michelson


let parse_do_transfers = function
  | Mprim { prim = `Pair; args = [
      _m_asset_class; _m_asset_data; _t_asset_class; _t_asset_data;
      _fill_m_value; _fill_t_value;
      left_maker; left_m_asset_class; left_m_asset_data; _left_m_asset_value;
      _left_taker; left_t_asset_class;  left_t_asset_data; _left_t_asset_value;
      Mint left_salt; _left_start; _left_end; _left_data_type; _left_data;
      right_maker; right_m_asset_class; right_m_asset_data; _right_m_asset_value;
      _right_taker; right_t_asset_class;  right_t_asset_data; _right_t_asset_value;
      Mint right_salt; _right_start; _right_end; _right_data_type; _right_data;
      _fee_side; _royalties
    ]; _ } ->
    let$ left_maker = parse_option_key left_maker in
    let$ left_mat = parse_asset_type left_m_asset_class left_m_asset_data in
    let$ left_tat = parse_asset_type left_t_asset_class left_t_asset_data in
    let left_salt = Z.to_string left_salt in
    let$ left = Utils.hash_key left_maker left_mat left_tat left_salt in
    let$ right_maker = parse_option_key right_maker in
    let$ right_mat = parse_asset_type right_m_asset_class right_m_asset_data in
    let$ right_tat = parse_asset_type right_t_asset_class right_t_asset_data in
    let right_salt = Z.to_string right_salt in
    let$ right = Utils.hash_key right_maker right_mat right_tat right_salt in
    Ok (DoTransfers {left; right})

  | _ -> unexpected_michelson

let rec parse_exchange e p =
  let p = flatten p in
  match e, p with
  | EPdefault, Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_exchange (EPnamed "left") m
  | EPnamed "left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_exchange (EPnamed "left_left") m
  | EPnamed "left_left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_exchange (EPnamed "left_left_left") m
  | EPnamed "left_left_left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_exchange (EPnamed "setValidator") m
  | EPnamed "left_left_left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_exchange (EPnamed "declareOwnership") m
  | EPnamed "left_left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_exchange (EPnamed "left_left_right") m
  | EPnamed "left_left_right", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_exchange (EPnamed "claimOwnership") m
  | EPnamed "left_left_right", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_exchange (EPnamed "setFeeReceiver") m
  | EPnamed "left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_exchange (EPnamed "left_right") m
  | EPnamed "left_right", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_exchange (EPnamed "left_right_left") m
  | EPnamed "left_right_left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_exchange (EPnamed "setDefaultReceiver") m
  | EPnamed "left_right_left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_exchange (EPnamed "cancel") m
  | EPnamed "left_right", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_exchange (EPnamed "left_right_right") m
  | EPnamed "left_right_right", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_exchange (EPnamed "setMetdataUri") m
  | EPnamed "left_right_right", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_exchange (EPnamed "setMetadataUriValidator") m
  | EPdefault, Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_exchange (EPnamed "right") m
  | EPnamed "right", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_exchange (EPnamed "right_left") m
  | EPnamed "right_left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_exchange (EPnamed "right_left_left") m
  | EPnamed "right_left_left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_exchange (EPnamed "setProtocolFee") m
  | EPnamed "right_left_left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_exchange (EPnamed "setExchangeContract") m
  | EPnamed "right_left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_exchange (EPnamed "right_left_right") m
  | EPnamed "right_left_right", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_exchange (EPnamed "setAssetMatcher") m
  | EPnamed "right_left_right", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_exchange (EPnamed "doTransfers") m
  | EPnamed "right", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_exchange (EPnamed "matchOrders") m

  | EPnamed "cancel", m -> parse_cancel m
  | EPnamed "doTransfers", m -> parse_do_transfers m
  | _ -> unexpected_michelson