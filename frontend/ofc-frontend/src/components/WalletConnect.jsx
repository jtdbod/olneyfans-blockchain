import { useState } from "react";
import detectEthereumProvider from "@metamask/detect-provider";

export default function WalletConnect({ onConnect }) {
  const [account, setAccount] = useState(null);

  async function connectWallet() {
    const provider = await detectEthereumProvider();
    if (!provider) {
      alert("MetaMask not detected. Please install MetaMask.");
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
