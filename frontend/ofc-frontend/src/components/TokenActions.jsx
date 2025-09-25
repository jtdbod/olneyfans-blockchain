import { useState, useEffect } from "react";
import { ethers } from "ethers";
import detectEthereumProvider from "@metamask/detect-provider";
import OFC_ABI from "../abis/OlneyFansCoin.json";

export default function TokenActions({ tokenAddress }) {
  const [balance, setBalance] = useState("0");
  const [account, setAccount] = useState(null);

  async function connectWallet() {
    const provider = await detectEthereumProvider();
    if (!provider) {
      alert("MetaMask not detected. Please install MetaMask.");
      return;
    }

    const accounts = await provider.request({
      method: "eth_requestAccounts",
    });
    setAccount(accounts[0]);
  }

  useEffect(() => {
    if (!window.ethereum) {
      console.error("MetaMask is not installed.");
      return;
    }

    console.log("window.ethereum:", window.ethereum);
    console.log("Token Address:", tokenAddress);

    async function fetchBalance() {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      console.log("Provider:", provider);
      const signer = provider.getSigner();
      const token = new ethers.Contract(tokenAddress, OFC_ABI, signer);
      const bal = await token.balanceOf(account);
      setBalance(ethers.utils.formatEther(bal));
    }

    if (account && tokenAddress) {
      fetchBalance();
    }
  }, [account, tokenAddress]);

  return (
    <div>
      <h3>Token Balance</h3>
      <p>{balance}</p>
      {account ? <p>Connected: {account}</p> : <button onClick={connectWallet}>Connect MetaMask</button>}
    </div>
  );
}
