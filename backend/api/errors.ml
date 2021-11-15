type error_elt = (string [@wrap "message"]) [@@deriving encoding]

type nonrec api_error = [
  | `UNKNOWN of error_elt [@code 500]
  | `VALIDATION of error_elt [@code 500]
  (* currency-controller *)
  | `FIRST_TEMPLATE_OBJECT_NOT_FOUND of error_elt [@code 500]
  | `SECOND_TEMPLATE_OBJECT_NOT_FOUND of error_elt [@code 500]
  (* nft-controllers *)
  | `BAD_REQUEST of error_elt [@code 500]
  | `TOKEN_PROPERTIES_EXTRACT of error_elt [@code 500]
  | `INCORRECT_LAZY_NFT of error_elt [@code 500]
  (* order-controllers *)
  | `INCORRECT_SIGNATURE of error_elt [@code 400]
  | `ORDER_CANCELED of error_elt [@code 400]
  | `ORDER_INVALID_UPDATE of error_elt [@code 400]
  | `INVALID_ARGUMENT of error_elt [@code 500]
  | `ABSENCE_OF_REQUIRED_FIELD of error_elt [@code 500]
  | `UNLOCKABLE_API_ERROR of error_elt [@code 500]
  | `NFT_API_ERROR of error_elt [@code 500]
  | `ORDER_API_ERROR of error_elt [@code 500]
  | `UNEXPECTED_API_ERROR of error_elt [@code 500]
  | `ORDER_NOT_FOUND of error_elt [@code 404]
  (* erc20-controllers *)
  | `TOKEN_NOT_FOUND of error_elt [@code 404]
  | `BALANCE_NOT_FOUND of error_elt [@code 404]
  (* nft-controllers *)
  | `ITEM_NOT_FOUND of error_elt [@code 404]
  | `LAZY_ITEM_NOT_FOUND of error_elt [@code 404]
  | `TOKEN_URI_NOT_FOUND of error_elt [@code 404]
  | `OWNERSHIP_NOT_FOUND of error_elt [@code 404]
  | `COLLECTION_NOT_FOUND of error_elt [@code 404]
  (* lock-controller *)
  | `LOCK_EXISTS of error_elt [@code 400]
  | `OWNERSHIP_ERROR of error_elt [@code 400]
] [@@deriving encoding, err_case {kind_label="code"; title}]

let string_of_error (e : [> api_error ]) =
  EzEncoding.construct api_error_enc e

let code_of_error : api_error -> int = function
  | `UNKNOWN _ -> 500
  | `VALIDATION _ -> 500
  | `FIRST_TEMPLATE_OBJECT_NOT_FOUND _ -> 500
  | `SECOND_TEMPLATE_OBJECT_NOT_FOUND _ -> 500
  | `BAD_REQUEST _ -> 500
  | `TOKEN_PROPERTIES_EXTRACT _ -> 500
  | `INCORRECT_LAZY_NFT _ -> 500
  | `INCORRECT_SIGNATURE _ -> 400
  | `ORDER_CANCELED _ -> 400
  | `ORDER_INVALID_UPDATE _ -> 400
  | `INVALID_ARGUMENT _ -> 500
  | `ABSENCE_OF_REQUIRED_FIELD _ -> 500
  | `UNLOCKABLE_API_ERROR _ -> 500
  | `NFT_API_ERROR _ -> 500
  | `ORDER_API_ERROR _ -> 500
  | `UNEXPECTED_API_ERROR _ -> 500
  | `ORDER_NOT_FOUND _ -> 404
  | `TOKEN_NOT_FOUND _ -> 404
  | `BALANCE_NOT_FOUND _ -> 404
  | `ITEM_NOT_FOUND _ -> 404
  | `LAZY_ITEM_NOT_FOUND _ -> 404
  | `TOKEN_URI_NOT_FOUND _ -> 404
  | `OWNERSHIP_NOT_FOUND _ -> 404
  | `COLLECTION_NOT_FOUND _ -> 404
  | `LOCK_EXISTS _ -> 400
  | `OWNERSHIP_ERROR _ -> 400
