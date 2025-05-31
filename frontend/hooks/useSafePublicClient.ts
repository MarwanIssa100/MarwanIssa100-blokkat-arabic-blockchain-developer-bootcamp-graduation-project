import { usePublicClient } from 'wagmi'
import { mainnet , scrollSepolia } from 'wagmi/chains'

export function useSafePublicClient() {
  const publicClient = usePublicClient({ chainId: scrollSepolia })
  if (!publicClient) {
    throw new Error('publicClient not available')
  }
  return publicClient
}