(
 (
  (Rule (typnam entrypoint))
  (
   (serialize "EzEncoding.construct Proto.entrypoint_enc.Proto.Encoding.json")
   (deserialize "EzEncoding.destruct Proto.entrypoint_enc.Proto.Encoding.json")
  )
 )

 (
  (Rule (typnam script_expr))
  (
   (serialize "EzEncoding.construct Proto.script_expr_enc.Proto.Encoding.json")
   (deserialize "EzEncoding.destruct Proto.script_expr_enc.Proto.Encoding.json")
  )
 )

 (
  (Or
   (
    (Rule (typnam zarith))
    (Rule (colnam last_token_id))
    (Rule (colnam counter))
    (Rule (colnam amount))
    (Rule (colnam supply))
    (Rule (colnam balance))
    (Rule (colnam make_asset_value))
    (Rule (colnam oleft_make_asset_value))
    (Rule (colnam oright_make_asset_value))
    (Rule (colnam take_asset_value))
    (Rule (colnam oleft_take_asset_value))
    (Rule (colnam oright_take_asset_value))
    (Rule (colnam make_value))
    (Rule (colnam take_value))
    (Rule (colnam fill_make_value))
    (Rule (colnam fill_take_value))
    )
   )
  (
   (serialize Z.to_string)
   (deserialize Z.of_string)
  )
 )

 (
  (Rule (typnam op_status))
  (
   (serialize op_status_to_string)
   (deserialize op_status_of_string)
  )
 )

 (
  (Rule (typnam node_errors))
  (
   (serialize "EzEncoding.construct (Json_encoding.list Proto.node_error_enc.Proto.Encoding.json)")
   (deserialize "EzEncoding.destruct (Json_encoding.list Proto.node_error_enc.Proto.Encoding.json)")
  )
 )

 (
  (Rule (typnam balance_update_kind))
  (
   (serialize bu_kind_to_string)
   (deserialize bu_kind_of_string)
  )
 )
)
