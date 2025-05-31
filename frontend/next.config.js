/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export', // Enables static export
  images: {
    unoptimized: true, // Required for static export
  },
  basePath: '/MarwanIssa100-blokkat-arabic-blockchain-developer-bootcamp-graduation-project',
  assetPrefix: '/MarwanIssa100-blokkat-arabic-blockchain-developer-bootcamp-graduation-project',
};

module.exports = nextConfig; 