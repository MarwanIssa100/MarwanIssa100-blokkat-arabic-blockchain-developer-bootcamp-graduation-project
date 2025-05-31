import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
};

module.exports = {
  output: 'export', // Enables static export
  images: {
    unoptimized: true, // Required for static export
  },
  basePath: '/MarwanIssa100-blokkat-arabic-blockchain-developer-bootcamp-graduation-project',
  assetPrefix: '/MarwanIssa100-blokkat-arabic-blockchain-developer-bootcamp-graduation-project',
};

export default nextConfig;
