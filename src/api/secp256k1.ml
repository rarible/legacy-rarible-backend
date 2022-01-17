open Libsecp256k1.External
open Tzfunc.Crypto

let context = Context.create ()

let verify_bytes ~(pk : pk) ~(signature : signature) ~bytes =
  try
    let pk = Key.read_pk_exn context @@ Bigstring.of_string (pk :> string) in
    let msg = Bigstring.of_string (Blake2b_32.hash [bytes] :> string) in
    let signature = Sign.read_exn context @@ Bigstring.of_string (signature :> string) in
    Ok (Sign.verify_exn context ~pk ~msg ~signature)
  with exn -> Error (`verify_exn exn)

let verify ~sppk ~spsig ~bytes =
  Result.bind (Curve.from_b58 sppk) @@ function
  | `ed25519 | `p256 -> Error `unknown_curve
  | `secp256k1 ->
    Result.bind (Curve.from_b58 spsig) @@ function
    | `ed25519 | `p256 -> Error `unknown_curve
    | `secp256k1 ->
      Result.bind (Pk.b58dec sppk) @@ fun pk ->
      Result.bind (Signature.b58dec spsig) @@ fun signature ->
      verify_bytes ~pk ~signature ~bytes
