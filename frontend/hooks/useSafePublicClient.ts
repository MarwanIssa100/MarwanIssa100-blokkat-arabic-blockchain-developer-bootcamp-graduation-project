import { usePublicClient } from 'wagmi'
import { mainnet } from 'wagmi/chains'

export function useSafePublicClient() {
  const publicClient = usePublicClient({ chain: scrollSepolia })
  if (!publicClient) {
    throw new Error('publicClient not available')
  }
  return publicClient
}