open Proto
open Rtypes

(*
(or
 (or
  (or
   (pair %balance_of (list %requests (pair (address %owner) (nat %token_id)))
         (contract (list (pair (pair (address %owner) (nat %token_id)) (nat %balance)))))
   (list %update_operators
         (or (pair (address %owner) (pair (address %operator) (nat %token_id)))
             (pair (address %owner) (pair (address %operator) (nat %token_id))))))
  (or
   (list %update_operators_for_all (or address address))
   (list %transfer (pair address (list (pair (address %to) (pair (nat %token_id) (nat %amount))))))))
 (or
  (or
   (pair %mint (nat %itokenid) (pair (address %iowner) (pair (nat %iamount) (list %royalties (pair (address %partAccount) (nat %partValue))))))
   (pair %burn (nat %itokenid) (pair (address %iowner) (nat %iamount))))
  (or
   (bytes %setMetadataUri)
   (pair %setTokenMetadata (nat %iTokenId) (map %iExtras string string)))))
*)

let rec flatten = function
  | Mprim { prim = `Pair; args; annots } ->
    let args = List.fold_left (fun acc x -> match flatten x with
        | Mprim { prim = `Pair; args; _ } -> acc @ args
        | _ -> acc @ [ x ]) [] args in
    let args = List.map flatten args in
    Mprim { prim = `Pair; args; annots }
  | Mprim {prim; args; annots} ->
    Mprim {prim; args = List.map flatten args; annots}
  | Mseq l -> Mseq (List.map flatten l)
  | m -> m

let parse_update_operators m =
  let rec aux acc = function
    | [] -> Ok acc
    | Mprim { prim = add; args = [
        Mprim { prim = `Pair; args = [
            Mstring op_owner;
            Mstring op_operator;
            Mint id;
          ]; _ }
      ]; _ } :: t ->
      begin match add with
        | `Left ->
          aux ({op_owner; op_operator; op_token_id = Z.to_int64 id; op_add=true} :: acc) t
        | `Right ->
          aux ({op_owner; op_operator; op_token_id = Z.to_int64 id; op_add=false} :: acc) t
        | _ -> Error `unexpected_michelson_value
      end
    | _ -> Error `unexpected_michelson_value in
  match m with
  | Mseq l -> begin match aux [] l with
      | Error e -> Error e
      | Ok l -> Ok (Operator_updates (List.rev l))
    end
  | _ -> Error `unexpected_michelson_value

let parse_update_operators_all m =
  let rec aux acc = function
    | [] -> Ok acc
    | Mprim { prim = `Left; args = [ Mstring operator ]; _} :: t ->
      aux ((operator, true) :: acc) t
    | Mprim { prim = `Right; args = [ Mstring operator ]; _} :: t ->
      aux ((operator, false) :: acc) t
    | _ -> Error `unexpected_michelson_value in
  match m with
  | Mseq l -> begin match aux [] l with
      | Error e -> Error e
      | Ok l -> Ok (Operator_updates_all (List.rev l))
    end
  | _ -> Error `unexpected_michelson_value

let parse_transfer m =
  let rec aux_to acc = function
    | [] -> Ok acc
    | Mprim { prim = `Pair; args = [
        Mstring tr_destination;
        Mint id;
        Mint amount;
      ]; _} :: t ->
      aux_to ({tr_destination; tr_token_id = Z.to_int64 id; tr_amount = Z.to_int64 amount} :: acc) t
    | _ -> Error `unexpected_michelson_value in
  let rec aux_from acc = function
    | [] -> Ok acc
    | Mprim { prim = `Pair; args = [
          Mstring tr_source;
          Mseq txs
        ]; _} :: t ->
      begin match aux_to [] txs with
        | Error e -> Error e
        | Ok txs -> aux_from ({ tr_source; tr_txs = List.rev txs } :: acc) t
      end
    | _ -> Error `unexpected_michelson_value in
  match m with
  | Mseq l -> begin match aux_from [] l with
      | Error e -> Error e
      | Ok l -> Ok (Transfers (List.rev l))
    end
  | _ -> Error `unexpected_michelson_value

let parse_mint = function
  | Mprim { prim = `Pair; args = [
      Mint id;
      Mstring tk_owner;
      Mint amount;
      Mseq royalties ]; _ } ->
    let mi_meta = [] in
    let mi_royalties = List.filter_map (function
        | Mprim { prim = `Elt; args = [ Mstring s; Mint i ]; _ } -> Some (s, Z.to_int64 i)
        | _ -> None) royalties in
    Ok (Mint_tokens {
        mi_op = { tk_op = { tk_token_id = Z.to_int64 id; tk_amount = Z.to_int64 amount };
                  tk_owner };
        mi_royalties; mi_meta })
  | _ -> Error `unexpected_michelson_value

let parse_burn = function
  | Mprim {prim = `Pair; args = [Mint id; Mstring tk_owner; Mint amount]; _ } ->
    Ok (Burn_tokens { tk_owner; tk_op = {
        tk_token_id = Z.to_int64 id; tk_amount = Z.to_int64 amount } })
  | _ -> Error `unexpected_michelson_value

let parse_metadata_uri = function
  | Mbytes h -> Ok (Metadata_uri (Hex.to_string h))
  | _ -> Error `unexpected_michelson_value

let parse_token_metadata = function
  | Mprim {prim = `Pair; args = [Mint id; Mseq l]; _ } ->
    let l = List.filter_map (function
        | Mprim { prim = `Elt; args = [ Mstring k; Mstring v ]; _ } ->
          Some (k, v)
        | _ -> None) l in
    Ok (Token_metadata (Z.to_int64 id, l))
  | _ -> Error `unexpected_michelson_value

let rec parse_nft e p =
  let p = flatten p in
  match e, p with
  (* main *)
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

  | _ -> Error `unexpected_michelson_value
