let kafka_section =
  EzAPI.Doc.{section_name = "kafka-controller"; section_docs = []}

[@@@get
  {register=true;
   path="/kafka/item";
   name="kafka_item";
   output=Rtypes.nft_item_event_enc;
   section=kafka_section}]

[@@@get
  {register=true;
   path="/kafka/order";
   name="kafka_order";
   output=Rtypes.order_event_enc Rtypes.A.big_decimal_enc;
   section=kafka_section}]

[@@@get
  {register=true;
   path="/kafka/ownership";
   name="kafka_ownership";
   output=Rtypes.nft_ownership_event_enc;
   section=kafka_section}]

[@@@get
  {register=true;
   path="/kafka/activity";
   name="kafka_activity";
   output=Rtypes.activity_type_enc Rtypes.A.big_decimal_enc;
   section=kafka_section}]

[@@@get
  {register=true;
   path="/kafka/collection";
   name="kafka_collection";
   output=Rtypes.nft_collection_event_enc;
   section=kafka_section}]
