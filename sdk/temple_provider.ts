import { TempleWallet } from '@temple-wallet/dapp'

export function temple_provider(name = "temple") {
  const wallet = new TempleWallet(name)
  return wallet
}
