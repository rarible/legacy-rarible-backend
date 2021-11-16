type order_error_code = [
  | `ORDER_INVALID_UPDATE
  | `ORDER_CANCELED
  | `INCORRECT_SIGNATURE
] [@enum] [@@deriving encoding]

type entity_not_found_code = [
  | `TOKEN_NOT_FOUND
  | `BALANCE_NOT_FOUND
  | `OWNERSHIP_NOT_FOUND
  | `ORDER_NOT_FOUND
  | `ITEM_NOT_FOUND
  | `COLLECTION_NOT_FOUND
  | `NOT_FOUND
] [@enum] [@@deriving encoding]

type bad_request_code = [
  | `BAD_REQUEST
  | `VALIDATION
] [@enum] [@@deriving encoding]

type unexpected_code = [ `UNEXPECTED_API_ERROR ] [@enum]
[@@deriving encoding]

type 'code api_error = {
  code: 'code;
  message: string
} [@@deriving encoding]

type order_error = order_error_code api_error [@@deriving encoding {title="OrderError"; def_title}]
type entity_not_found = entity_not_found_code api_error [@@deriving encoding {title="EntityNotFound"; def_title}]
type bad_request = bad_request_code api_error [@@deriving encoding {title="BadRequest"; def_title}]
type unexpected = unexpected_code api_error [@@deriving encoding {title="ServerError"; def_title}]

type error_codes = [
  | order_error_code
  | entity_not_found_code
  | bad_request_code
  | unexpected_code
] [@@deriving encoding]

type api_error_all = error_codes api_error

let code_of_error (e : error_codes api_error) = match e.code with
  | #order_error_code -> 400
  | #entity_not_found_code -> 404
  | #bad_request_code -> 400
  | #unexpected_code -> 500

let order_error_case =
  let select (e : api_error_all) = match e.code with
    | #order_error_code as code -> Some { e with code } | _ -> None in
  let deselect (e : order_error) = (e :> api_error_all) in
  EzAPI.Err.make ~code:400 ~name:"OrderDataError" ~encoding:order_error_enc
    ~select ~deselect

let entity_not_found_case =
  let select (e : api_error_all) = match e.code with
    | #entity_not_found_code as code -> Some { e with code } | _ -> None in
  let deselect (e : entity_not_found) = (e :> api_error_all) in
  EzAPI.Err.make ~code:404 ~name:"EntityNotFound" ~encoding:entity_not_found_enc
    ~select ~deselect

let bad_request_case =
  let select (e : error_codes api_error) = match e.code with
    | #bad_request_code as code -> Some { e with code } | _ -> None in
  let deselect (e : bad_request) = (e :> api_error_all) in
  EzAPI.Err.make ~code:400 ~name:"BadRequest" ~encoding:bad_request_enc
    ~select ~deselect

let unexpected_case =
  let select (e : error_codes api_error) = match e.code with
    | #unexpected_code as code -> Some { e with code } | _ -> None in
  let deselect (e : unexpected) = (e :> api_error_all) in
  EzAPI.Err.make ~code:500 ~name:"ServerError" ~encoding:unexpected_enc
    ~select ~deselect

let string_of_error e =
  EzEncoding.construct (api_error_enc error_codes_enc) e

(* type error_elt = (string [@wrap "message"]) [@@deriving encoding] *)

(* type nonrec api_error = [
 *   | `UNKNOWN of error_elt [@code 500]
 *   | `VALIDATION of error_elt [@code 500]
 *   (\* currency-controller *\)
 *   | `FIRST_TEMPLATE_OBJECT_NOT_FOUND of error_elt [@code 500]
 *   | `SECOND_TEMPLATE_OBJECT_NOT_FOUND of error_elt [@code 500]
 *   (\* nft-controllers *\)
 *   | `BAD_REQUEST of error_elt [@code 400]
 *   | `TOKEN_PROPERTIES_EXTRACT of error_elt [@code 500]
 *   | `INCORRECT_LAZY_NFT of error_elt [@code 500]
 *   (\* order-controllers *\)
 *   | `INCORRECT_SIGNATURE of error_elt [@code 400]
 *   | `ORDER_CANCELED of error_elt [@code 400]
 *   | `ORDER_INVALID_UPDATE of error_elt [@code 400]
 *   | `INVALID_ARGUMENT of error_elt [@code 500]
 *   | `ABSENCE_OF_REQUIRED_FIELD of error_elt [@code 500]
 *   | `UNLOCKABLE_API_ERROR of error_elt [@code 500]
 *   | `NFT_API_ERROR of error_elt [@code 500]
 *   | `ORDER_API_ERROR of error_elt [@code 500]
 *   | `UNEXPECTED_API_ERROR of error_elt [@code 500]
 *   | `ORDER_NOT_FOUND of error_elt [@code 404]
 *   (\* erc20-controllers *\)
 *   | `TOKEN_NOT_FOUND of error_elt [@code 404]
 *   | `BALANCE_NOT_FOUND of error_elt [@code 404]
 *   (\* nft-controllers *\)
 *   | `ITEM_NOT_FOUND of error_elt [@code 404]
 *   | `LAZY_ITEM_NOT_FOUND of error_elt [@code 404]
 *   | `TOKEN_URI_NOT_FOUND of error_elt [@code 404]
 *   | `OWNERSHIP_NOT_FOUND of error_elt [@code 404]
 *   | `COLLECTION_NOT_FOUND of error_elt [@code 404]
 *   (\* lock-controller *\)
 *   | `LOCK_EXISTS of error_elt [@code 400]
 *   | `OWNERSHIP_ERROR of error_elt [@code 400]
 * ] [@@deriving encoding, err_case {kind_label="code"; title}] *)

(* let string_of_error (e : [> api_error ]) =
 *   EzEncoding.construct api_error_enc e
 *
 * let code_of_error : api_error -> int = function
 *   | `UNKNOWN _ -> 500
 *   | `VALIDATION _ -> 500
 *   | `FIRST_TEMPLATE_OBJECT_NOT_FOUND _ -> 500
 *   | `SECOND_TEMPLATE_OBJECT_NOT_FOUND _ -> 500
 *   | `BAD_REQUEST _ -> 400
 *   | `TOKEN_PROPERTIES_EXTRACT _ -> 500
 *   | `INCORRECT_LAZY_NFT _ -> 500
 *   | `INCORRECT_SIGNATURE _ -> 400
 *   | `ORDER_CANCELED _ -> 400
 *   | `ORDER_INVALID_UPDATE _ -> 400
 *   | `INVALID_ARGUMENT _ -> 500
 *   | `ABSENCE_OF_REQUIRED_FIELD _ -> 500
 *   | `UNLOCKABLE_API_ERROR _ -> 500
 *   | `NFT_API_ERROR _ -> 500
 *   | `ORDER_API_ERROR _ -> 500
 *   | `UNEXPECTED_API_ERROR _ -> 500
 *   | `ORDER_NOT_FOUND _ -> 404
 *   | `TOKEN_NOT_FOUND _ -> 404
 *   | `BALANCE_NOT_FOUND _ -> 404
 *   | `ITEM_NOT_FOUND _ -> 404
 *   | `LAZY_ITEM_NOT_FOUND _ -> 404
 *   | `TOKEN_URI_NOT_FOUND _ -> 404
 *   | `OWNERSHIP_NOT_FOUND _ -> 404
 *   | `COLLECTION_NOT_FOUND _ -> 404
 *   | `LOCK_EXISTS _ -> 400
 *   | `OWNERSHIP_ERROR _ -> 400 *)
