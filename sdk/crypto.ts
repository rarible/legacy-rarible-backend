const hacl = require("hacl-wasm")
const bs58check = require('bs58check')
const crypto = require("crypto")

interface Keys {
  sk : string;
  pk : string;
  pkh : string;
}

const size = 32
const tz1_prefix =  new Uint8Array([6, 161, 159])
const edpk_prefix =  new Uint8Array([13, 15, 37, 217])
const edsk_prefix = new Uint8Array([13, 15, 58, 7])

async function get_hacl() : Promise<any> {
  return await hacl.getInitializedHaclModule()
}

function b58enc(payload: Uint8Array, prefix: Uint8Array) {
  const n = new Uint8Array(prefix.length + payload.length);
  n.set(prefix);
  n.set(payload, prefix.length);
  return bs58check.encode(Buffer.from(n.buffer));
}

function b58dec(enc : string, prefix : Uint8Array) : Uint8Array {
  return bs58check.decode(enc).slice(prefix.length)
}

function random(n = size) : Uint8Array {
  return new Uint8Array(crypto.randomBytes(n))
}

async function sk_to_pk(sk : Uint8Array) : Promise<Uint8Array> {
  let h = await get_hacl()
  return h.Ed25519.secret_to_public(sk)[0]
}

async function pk_to_pkh(pk : Uint8Array) : Promise<Uint8Array> {
  let h = await get_hacl()
  return h.Blake2.blake2b(20, pk, new Uint8Array(0))[0]
}

async function generate_keys() : Promise<Keys> {
  let sk_bytes = random()
  let pk_bytes = await sk_to_pk(sk_bytes)
  let pkh_bytes = await pk_to_pkh(pk_bytes)
  return {
    sk : b58enc(sk_bytes, edsk_prefix),
    pk : b58enc(pk_bytes, edpk_prefix),
    pkh : b58enc(pkh_bytes, tz1_prefix)
  }
}

export {
  tz1_prefix,
  edpk_prefix,
  edsk_prefix,
  size,
  b58enc,
  b58dec,
  random,
  sk_to_pk,
  pk_to_pkh,
  generate_keys,
}
