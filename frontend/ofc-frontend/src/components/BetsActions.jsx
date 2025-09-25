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
