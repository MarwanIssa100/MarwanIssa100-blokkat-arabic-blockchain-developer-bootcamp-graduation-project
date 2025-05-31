# SparkUp

## About the Project 
SparkUp is an innovative crowdfunding platform that connects creative project ideas with potential investors. Our platform enables entrepreneurs and innovators to showcase their ideas and receive funding from interested backers who believe in their vision.

## Directory Structure

```
frontend/
├── app/
│   └── page.tsx  (all front end logic)
├── config/
│   └── index.tsx (wagmi config)
└── context/
    └── index.tsx (context provider)    

SparkUp/                
├── foundry.toml      (foundry config)    
├── src/                   
│   └── SparkUp.sol  (smart contract)      
└── test/                   
    └── SparkUp.t.sol (unit test file)                    
```

## Design Patterns
1. Importing and extending contracts:
   - Ownable module from OpenZeppelin 

   

2. Restricting access to certain functions using Ownable 

3. Creating more efficient Solidity code

## Security Best Practices

1. Using Specific Compiler Pragma

2. Proper Use of Require

3. Use Modifiers Only for Validation 

4. Checks-Effects-Interactions

## Important Links & Addresses

### Contract Address 
`0xCF85AE46F9254D28338E54a10810877Db54b2bAF`

### Contract Link
[View on ScrollScan](https://sepolia.scrollscan.com/address/0xCF85AE46F9254D28338E54a10810877Db54b2bAF)

### frontend link
https://spark-gzmy1n90g-marwanissa100s-projects.vercel.app/

## How to Run Tests

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```bash
   cd <project-directory>
   ```

3. Install dependencies:
   ```bash
   forge install
   ```

4. Run tests:
   ```bash
   forge test
   ```

## How to Run the Program

1. Install dependencies:
   ```bash
   # Install Foundry dependencies
   forge install
   
   # Install frontend dependencies
   cd frontend
   npm install
   ```

2. Start the development server:
   ```bash
   # In the frontend directory
   npm run dev
   ```

3. Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Demo
[Watch Demo Video](https://youtu.be/Gu1_duL6PXw)