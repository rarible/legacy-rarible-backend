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
   output=Rtypes.order_event_enc;
   section=kafka_section}]

[@@@get
  {register=true;
   path="/kafka/ownership";
   name="kafka_ownership";
   output=Rtypes.nft_ownership_event_enc;
   section=kafka_section}]

[@@@get
  {register=true;
   path="/kafka/nft_activity";
   name="kafka_nft_activity";
   output=Rtypes.nft_activity_enc;
   section=kafka_section}]

[@@@get
  {register=true;
   path="/kafka/order_activity";
   name="kafka_order_activity";
   output=Rtypes.order_activity_enc;
   section=kafka_section}]

let () =
  EzOpenAPI.executable ~sections:[kafka_section] ~docs:[]
