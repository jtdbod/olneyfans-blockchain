// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OlneyFansCoin is ERC20, Ownable {
    uint256 public constant BURN_TAX = 1; // 1% burn

    constructor(uint256 initialSupply) ERC20("OlneyFansCoin", "OFC") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }

    // Use _beforeTokenTransfer hook for burn logic (v5.4-compatible)
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (from == address(0) || to == address(0) || BURN_TAX == 0) return;

        uint256 burnAmount = (amount * BURN_TAX) / 100;
        if (burnAmount > 0) _burn(from, burnAmount);
    }

    // Owner mint function
    function ownerMint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
