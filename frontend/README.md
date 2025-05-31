# SparkUp Frontend

This is the frontend application for SparkUp, built with [Next.js](https://nextjs.org) and [Wagmi](https://wagmi.sh) for blockchain interactions.

## Features

- Modern UI built with Next.js 13+ (App Router)
- Blockchain integration using Wagmi and viem
- Smart contract interaction for crowdfunding
- Responsive design
- Real-time updates

## Prerequisites

- Node.js 16.8 or later
- npm or yarn
- MetaMask or another Web3 wallet

## Getting Started

1. Install dependencies:
   ```bash
   npm install
   # or
   yarn install
   ```

2. Create a `.env.local` file in the root directory with the following variables:
   ```
   NEXT_PUBLIC_CONTRACT_ADDRESS=0xCF85AE46F9254D28338E54a10810877Db54b2bAF
   NEXT_PUBLIC_NETWORK_ID=534351  # Scroll Sepolia
   ```

3. Run the development server:
   ```bash
   npm run dev
   # or
   yarn dev
   ```

4. Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Project Structure

```
frontend/
├── app/              # Next.js app directory
├── config/           # Wagmi configuration
├── context/          # React context providers
├── public/           # Static assets
└── styles/           # Global styles
```

## Deployment

The application is configured for deployment on Netlify. The build settings are defined in `netlify.toml`.

## Learn More

- [Next.js Documentation](https://nextjs.org/docs)
- [Wagmi Documentation](https://wagmi.sh)
- [Scroll Documentation](https://docs.scroll.io)
