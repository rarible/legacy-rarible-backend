open Proto
open Rtypes

(* type tree =
 *   | Node of (string * tree * tree)
 *   | Leaf of string
 *
 * let t =
 *   Node (
 *     "",
 *     Node (
 *       "main_left",
 *       Node (
 *         "admin",
 *         Node (
 *           "admin_left",
 *           Node (
 *             "admin_left_left",
 *             Leaf "confirm_admin",
 *             Leaf "confirm_company_wallet"),
 *           Node (
 *             "admin_left_right",
 *             Leaf "pause",
 *             Leaf "set_admin")),
 *         Leaf "set_company_wallet"),
 *       Node (
 *         "assets",
 *         Node (
 *           "fa2",
 *           Node (
 *             "fa2_left",
 *             Leaf "balance_of",
 *             Leaf "managed"),
 *           Node (
 *             "fa2_right",
 *             Leaf "transfer",
 *             Leaf "udapte_operators")),
 *         Leaf "token_metadata")),
 *     Node (
 *       "tokens",
 *       Leaf "burn_tokens",
 *       Leaf "mint_tokens")) *)

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

let parse_update m =
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

let parse_mint = function
  | Mprim { prim = `Pair; args = [
      Mint from_;
      Mint _to_;
      Mint _id;
      Mseq meta;
      Mseq owners ]; _ } ->
    let tk_meta = List.filter_map (function
        | Mprim { prim = `Elt; args = [ Mstring s; Mbytes (`Hex h) ]; _ } -> Some (s, h)
        | _ -> None) meta in
    let owners = List.filter_map (function Mstring s -> Some s | _ -> None) owners in
    Ok (Mint_tokens (List.mapi (fun i tk_owner -> {
          tk_own = {
            tk_op = {
              tk_token_id = Int64.(add (Z.to_int64 from_) (of_int i));
              tk_amount = 1L };
            tk_owner };
          tk_meta}) owners))
  | _ -> Error `unexpected_michelson_value

let parse_burn = function
  | Mprim {prim = `Pair; args = [Mint from_; Mint to_]; _ } ->
    Ok (Burn_tokens (List.init Z.(to_int @@ sub to_ from_) (fun i ->
        {tk_token_id  = Int64.(add (Z.to_int64 from_) (of_int i));
         tk_amount = 1L})))
  | _ -> Error `unexpected_michelson_value

let parse_set_company_wallet _ = Error `unexpected_michelson_value
let parse_set_admin _ = Error `unexpected_michelson_value
let parse_pause _ = Error `unexpected_michelson_value
let parse_confirm_company_wallet _ = Error `unexpected_michelson_value
let parse_confirm_admin _ = Error `unexpected_michelson_value
let parse_token_metadata _ = Error `unexpected_michelson_value
let parse_managed _ = Error `unexpected_michelson_value
let parse_balance_of _ = Error `unexpected_michelson_value

let rec parse e p =
  let p = flatten p in
  match e, p with
  (* main *)
  | EPdefault, Mprim { prim = `Right; args = [ m ]; _ } ->
    parse (EPnamed "tokens") m
  | EPdefault, Mprim { prim = `Left; args = [ m ]; _ } ->
    parse (EPnamed "main_left") m

  (* tokens *)
  | EPnamed "tokens", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse (EPnamed "mint_tokens") m
  | EPnamed "tokens", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse (EPnamed "burn_tokens") m
  | EPnamed "mint_tokens", m -> parse_mint m
  | EPnamed "burn_tokens", m -> parse_burn m
  | EPnamed "main_left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse (EPnamed "assets") m
  | EPnamed "main_left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse (EPnamed "admin") m

  (* admin *)
  | EPnamed "admin", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse (EPnamed "set_company_wallet") m
  | EPnamed "admin", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse (EPnamed "admin_left") m
  | EPnamed "admin_left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse (EPnamed "admin_left_right") m
  | EPnamed "admin_left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse (EPnamed "admin_left_left") m
  | EPnamed "admin_left_right", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse (EPnamed "set_admin") m
  | EPnamed "admin_left_right", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse (EPnamed "pause") m
  | EPnamed "admin_left_left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse (EPnamed "confirm_company_wallet") m
  | EPnamed "admin_left_left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse (EPnamed "confirm_admin") m
  | EPnamed "set_company_wallet", m -> parse_set_company_wallet m
  | EPnamed "set_admin", m -> parse_set_admin m
  | EPnamed "pause", m -> parse_pause m
  | EPnamed "confirm_company_wallet", m -> parse_confirm_company_wallet m
  | EPnamed "confirm_admin", m -> parse_confirm_admin m

  (* assets *)
  | EPnamed "assets", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse (EPnamed "token_metadata") m
  | EPnamed "assets", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse (EPnamed "fa2") m

  (* fa2 *)
  | EPnamed "fa2", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse (EPnamed "fa2_right") m
  | EPnamed "fa2", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse (EPnamed "fa2_left") m
  | EPnamed "fa2_right", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse (EPnamed "update_operators") m
  | EPnamed "fa2_right", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse (EPnamed "transfer") m
  | EPnamed "fa2_left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse (EPnamed "managed") m
  | EPnamed "fa2_left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse (EPnamed "balance_of") m
  | EPnamed "token_metadata", m -> parse_token_metadata m
  | EPnamed "update_operators", m -> parse_update m
  | EPnamed "transfer", m -> parse_transfer m
  | EPnamed "managed", m -> parse_managed m
  | EPnamed "balance_of", m -> parse_balance_of m
  | _ -> Error `unexpected_michelson_value
