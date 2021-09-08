open Rtypes

let rarible_error_500 =
  EzAPI.Err.make
    ~code:500
    ~name:"Rarible 500 Error"
    ~encoding:rarible_error_500_enc
    ~select:(fun k -> Some k)
    ~deselect:(fun k -> k)

let rarible_error_400 =
  EzAPI.Err.make
    ~code:400
    ~name:"Rarible 400 Error"
    ~encoding:rarible_error_400_enc
    ~select:(fun k -> Some k)
    ~deselect:(fun k -> k)

let rarible_error_404 =
  EzAPI.Err.make
    ~code:404
    ~name:"Rarible 404 Error"
    ~encoding:rarible_error_404_enc
    ~select:(fun k -> Some k)
    ~deselect:(fun k -> k)

let unknown_error msg = {
  rarible_error_500_status = 500;
  rarible_error_500_message = msg;
  rarible_error_500_code = UNKNOWN;
}

let validation_error msg = {
  rarible_error_500_status = 500;
  rarible_error_500_message = msg;
  rarible_error_500_code = VALIDATION;
}

let first_template_object_not_found msg = {
  rarible_error_500_status = 500;
  rarible_error_500_message = msg;
  rarible_error_500_code = FIRST_TEMPLATE_OBJECT_NOT_FOUND;
}

let second_template_object_not_found msg = {
  rarible_error_500_status = 500;
  rarible_error_500_message = msg;
  rarible_error_500_code = SECOND_TEMPLATE_OBJECT_NOT_FOUND;
}

let bad_request msg = {
  rarible_error_500_status = 500;
  rarible_error_500_message = msg;
  rarible_error_500_code = BAD_REQUEST;
}

let token_properties_extract msg = {
  rarible_error_500_status = 500;
  rarible_error_500_message = msg;
  rarible_error_500_code = TOKEN_PROPERTIES_EXTRACT;
}

let incorrect_lazy_nft msg = {
  rarible_error_500_status = 500;
  rarible_error_500_message = msg;
  rarible_error_500_code = INCORRECT_LAZY_NFT;
}

let invalid_argument msg = {
  rarible_error_500_status = 500;
  rarible_error_500_message = msg;
  rarible_error_500_code = INVALID_ARGUMENT;
}

let absence_of_required_field msg = {
  rarible_error_500_status = 500;
  rarible_error_500_message = msg;
  rarible_error_500_code = ABSENCE_OF_REQUIRED_FIELD;
}

let unlockable_api_error msg = {
  rarible_error_500_status = 500;
  rarible_error_500_message = msg;
  rarible_error_500_code = UNLOCKABLE_API_ERROR;
}

let nft_api_error msg = {
  rarible_error_500_status = 500;
  rarible_error_500_message = msg;
  rarible_error_500_code = NFT_API_ERROR;
}

let order_api_error msg = {
  rarible_error_500_status = 500;
  rarible_error_500_message = msg;
  rarible_error_500_code = ORDER_API_ERROR;
}

let unexpected_api_error msg = {
  rarible_error_500_status = 500;
  rarible_error_500_message = msg;
  rarible_error_500_code = UNEXPECTED_API_ERROR;
}

let token_not_found msg = {
  rarible_error_404_status = 404;
  rarible_error_404_message = msg;
  rarible_error_404_code = TOKEN_NOT_FOUND;
}

let balance_not_found msg = {
  rarible_error_404_status = 404;
  rarible_error_404_message = msg;
  rarible_error_404_code = BALANCE_NOT_FOUND;
}

let item_not_found msg = {
  rarible_error_404_status = 404;
  rarible_error_404_message = msg;
  rarible_error_404_code = ITEM_NOT_FOUND;
}

let lazy_item_not_found msg = {
  rarible_error_404_status = 404;
  rarible_error_404_message = msg;
  rarible_error_404_code = LAZY_ITEM_NOT_FOUND;
}

let token_uri_not_found msg = {
  rarible_error_404_status = 404;
  rarible_error_404_message = msg;
  rarible_error_404_code = TOKEN_URI_NOT_FOUND;
}

let ownership_not_found msg = {
  rarible_error_404_status = 404;
  rarible_error_404_message = msg;
  rarible_error_404_code = OWNERSHIP_NOT_FOUND;
}

let collection_not_found msg = {
  rarible_error_404_status = 404;
  rarible_error_404_message = msg;
  rarible_error_404_code = COLLECTION_NOT_FOUND;
}

let lock_exists msg = {
  rarible_error_400_status = 400;
  rarible_error_400_message = msg;
  rarible_error_400_code = LOCK_EXISTS;
}

let ownership_error msg = {
  rarible_error_400_status = 400;
  rarible_error_400_message = msg;
  rarible_error_400_code = OWNERSHIP_ERROR;
}

