//SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import {ERC1155} from "openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IVerifier} from "./Verifier.sol";
import {IPanagram} from "./interfaces/IPanagram.sol";

contract Panagram is IPanagram, ERC1155, Ownable {
    // Constants
    uint256 public constant MIN_ROUND_DURATION = 10800; // 3 hours

    // Storage variables
    IVerifier public verifier;
    uint256 public roundStartTime;
    bytes32 public answer;
    address public currentRoundWinner;
    uint256 public currentRound;
    mapping(address user => uint256 lastRoundGuessedCorrectly) public lastRoundGuessedCorrectly;

    constructor(IVerifier _verifier)
        Ownable(msg.sender)
        ERC1155("ipfs://QmWpqYX9kL5osYWimiGetVkKHSVwdBHp9JYp3Lq2LPrWTt/{id}.json")
    {
        verifier = _verifier;
    }

    function newRound(bytes32 _answer) external onlyOwner {
        require(block.timestamp - roundStartTime >= MIN_ROUND_DURATION, RoundMinDurationNotPassed());
        require(currentRoundWinner != address(0) || currentRound == 0, NoRoundWinner());
        answer = _answer;
        // Reset the round state
        roundStartTime = block.timestamp;
        currentRoundWinner = address(0);
        currentRound++;
        emit NewRoundStarted(_answer);
    }

    function makeGuess(bytes memory proof) external returns (bool) {
        require(roundStartTime > 0, FirstRoundNotStarted());
        require(lastRoundGuessedCorrectly[msg.sender] != currentRound, UserAlreadyGuessedCorrectly());

        bytes32[] memory inputs = new bytes32[](2);
        inputs[0] = answer;
        inputs[1] = bytes32(uint256(uint160(msg.sender)));
        bool valid = verifier.verify(proof, inputs);

        if (!valid) {
            return false;
        }

        // No one has yet guessed correctly in this round
        if (currentRoundWinner == address(0)) {
            _mint(msg.sender, 0, 1, "");
            currentRoundWinner = msg.sender;
            emit WinnerCrowned(msg.sender, currentRound);
        } else {
            _mint(msg.sender, 1, 1, "");
        }
        lastRoundGuessedCorrectly[msg.sender] = currentRound;

        return true;
    }

    function setVerifier(IVerifier _verifier) external onlyOwner {
        IVerifier oldVerifier = verifier;
        verifier = _verifier;
        emit VerifierChanged(address(oldVerifier), address(_verifier));
    }
}
