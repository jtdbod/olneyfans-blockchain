// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FantasyFootballBets is Ownable {
    IERC20 public immutable token;

    struct Bet {
        address player1;
        address player2;
        uint256 amount;
        bool accepted;
        bool active;
        address winner;
    }

    uint256 public betCounter;
    mapping(uint256 => Bet) public bets;

    event BetCreated(uint256 betId, address player1, address player2, uint256 amount);
    event BetAccepted(uint256 betId, address player2);
    event BetResolved(uint256 betId, address winner, uint256 payout);

    constructor(address tokenAddress) Ownable(msg.sender) {
        require(tokenAddress != address(0), "Invalid token address");
        token = IERC20(tokenAddress);
    }

    function createBet(address opponent, uint256 amount) external returns (uint256) {
        require(opponent != msg.sender, "Cannot bet yourself");
        require(amount > 0, "Amount must be > 0");

        token.transferFrom(msg.sender, address(this), amount);

        betCounter++;
        bets[betCounter] = Bet({
            player1: msg.sender,
            player2: opponent,
            amount: amount,
            accepted: false,
            active: true,
            winner: address(0)
        });

        emit BetCreated(betCounter, msg.sender, opponent, amount);
        return betCounter;
    }

    function acceptBet(uint256 betId) external {
        Bet storage b = bets[betId];
        require(b.active, "Bet not active");
        require(!b.accepted, "Already accepted");
        require(msg.sender == b.player2, "Only invited opponent");

        token.transferFrom(msg.sender, address(this), b.amount);
        b.accepted = true;

        emit BetAccepted(betId, msg.sender);
    }

    function resolveBet(uint256 betId, address winner) external onlyOwner {
        Bet storage b = bets[betId];
        require(b.active, "Bet not active");
        require(b.accepted, "Bet not accepted");
        require(winner == b.player1 || winner == b.player2, "Winner must be a participant");

        uint256 payout = b.amount * 2;
        b.active = false;
        b.winner = winner;

        token.transfer(winner, payout);

        emit BetResolved(betId, winner, payout);
    }
}
