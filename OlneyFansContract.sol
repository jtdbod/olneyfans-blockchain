// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OlneyFansCoin is ERC20, Ownable {
    mapping(address => uint256) public stakedBalance;

    uint256 public constant BURN_TAX = 1; // 1%

    constructor() ERC20("OlneyFansCoin", "OFC") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // Use _update instead of _transfer
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (from != address(0) && to != address(0)) {
            // normal transfer with tax
            uint256 burnAmount = (amount * BURN_TAX) / 100;
            uint256 transferAmount = amount - burnAmount;

            super._update(from, address(0), burnAmount); // burn portion
            super._update(from, to, transferAmount);     // send portion
        } else {
            // minting or burning, just use the default behavior
            super._update(from, to, amount);
        }
    }

    function stake(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        _burn(msg.sender, amount);
        stakedBalance[msg.sender] += amount;
    }

    function unstake(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked balance");
        
        uint256 reward = (amount * 10) / 100;
        
        stakedBalance[msg.sender] -= amount;
        _mint(msg.sender, amount + reward);
    }
}
