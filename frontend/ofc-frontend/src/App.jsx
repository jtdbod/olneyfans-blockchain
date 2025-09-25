import { useState } from "react";
import WalletConnect from "./components/WalletConnect";
import TokenActions from "./components/TokenActions";
import BetsActions from "./components/BetsActions";
import { ethers } from "ethers";

function App() {
  const [account, setAccount] = useState(null);

  const tokenAddress = import.meta.env.VITE_OFC_ADDRESS;
  const betsAddress = import.meta.env.VITE_BETS_ADDRESS;

  if (!tokenAddress || !betsAddress) {
    console.error("Contract addresses are not defined. Check your .env file.");
    return <p>Error: Contract addresses are missing.</p>;
  }

  return (
    <div>
      <h1>Olney Fans League Test</h1>
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
