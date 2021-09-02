type z = Z.t [@encoding Json_encoding.(conv Z.to_string Z.of_string string)] [@@deriving encoding]

type erc20_balance = {
  contract : string;
  owner : string;
  balance : z;
  decimal_balance : z; [@camel]
} [@@deriving encoding]
