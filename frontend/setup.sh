#!/bin/bash
set -e

APP_NAME="ofc-frontend"

# 1️⃣ Create Vite React project
npm create vite@latest $APP_NAME -- --template react
cd $APP_NAME

# 2️⃣ Install dependencies
npm install ethers @metamask/detect-provider react-toastify

# 3️⃣ Create folders
mkdir -p src/abis src/components

# 4️⃣ WalletConnect component
cat <<EOL > src/components/WalletConnect.jsx
import { useState } from "react";
import detectEthereumProvider from "@metamask/detect-provider";

export default function WalletConnect({ onConnect }) {
  const [account, setAccount] = useState(null);

  async function connectWallet() {
    const provider = await detectEthereumProvider();
    if (!provider) {
      alert("MetaMask not detected");
      return;
    }

    const accounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    setAccount(accounts[0]);
    onConnect(accounts[0]);
  }

  return (
    <div>
      {account ? <p>Connected: {account}</p> : <button onClick={connectWallet}>Connect MetaMask</button>}
    </div>
  );
}
EOL

# 5️⃣ TokenActions component
cat <<EOL > src/components/TokenActions.jsx
import { useState } from "react";
import { ethers } from "ethers";
import OFC_ABI from "../abis/OlneyFansCoin.json";

export default function TokenActions({ account, tokenAddress }) {
  const [balance, setBalance] = useState(0);

  async function fetchBalance() {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const token = new ethers.Contract(tokenAddress, OFC_ABI, provider);
    const bal = await token.balanceOf(account);
    setBalance(ethers.utils.formatEther(bal));
  }

  async function transferTokens(to, amount) {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const token = new ethers.Contract(tokenAddress, OFC_ABI, signer);

    const tx = await token.transfer(to, ethers.utils.parseEther(amount.toString()));
    await tx.wait();
    fetchBalance();
  }

  return (
    <div>
      <h3>Token Actions</h3>
      <p>Balance: {balance}</p>
      <button onClick={fetchBalance}>Refresh Balance</button>
      {/* Add transfer form here */}
    </div>
  );
}
EOL

# 6️⃣ BetsActions component
cat <<EOL > src/components/BetsActions.jsx
import { useState } from "react";
import { ethers } from "ethers";
import BETS_ABI from "../abis/FantasyFootballBets.json";

export default function BetsActions({ account, betsAddress }) {
  const [bets, setBets] = useState([]);

  async function fetchBets() {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const contract = new ethers.Contract(betsAddress, BETS_ABI, provider);
    // Replace with your actual view function to get bets
    const allBets = await contract.getAllBets();
    setBets(allBets);
  }

  async function createBet(opponent, amount) {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(betsAddress, BETS_ABI, signer);
    const tx = await contract.createBet(opponent, ethers.utils.parseEther(amount.toString()));
    await tx.wait();
    fetchBets();
  }

  return (
    <div>
      <h3>Bets Actions</h3>
      <button onClick={fetchBets}>Refresh Bets</button>
      {/* Add form for creating bet */}
      <pre>{JSON.stringify(bets, null, 2)}</pre>
    </div>
  );
}
EOL

# 7️⃣ App.jsx
cat <<EOL > src/App.jsx
import { useState } from "react";
import WalletConnect from "./components/WalletConnect";
import TokenActions from "./components/TokenActions";
import BetsActions from "./components/BetsActions";

function App() {
  const [account, setAccount] = useState(null);

  // Replace these with your deployed addresses
  const tokenAddress = import.meta.env.VITE_OFC_ADDRESS;
  const betsAddress = import.meta.env.VITE_BETS_ADDRESS;

  return (
    <div>
      <h1>Olney Fans League</h1>
      <WalletConnect onConnect={setAccount} />
      {account && (
        <>
          <TokenActions account={account} tokenAddress={tokenAddress} />
          <BetsActions account={account} betsAddress={betsAddress} />
        </>
      )}
    </div>
  );
}

export default App;
EOL

# 8️⃣ Dockerfile
cat <<EOL > Dockerfile
# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM nginx:stable-alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOL

echo "Full frontend scaffold created in ./$APP_NAME"
echo "Don't forget to add your contract ABIs to src/abis and set VITE_OFC_ADDRESS & VITE_BETS_ADDRESS in a .env file"
