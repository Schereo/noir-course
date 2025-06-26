//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IVerifier} from "../Verifier.sol";

interface IPanagram {
    // Events
    event VerifierChanged(address indexed oldVerifier, address indexed newVerifier);
    event NewRoundStarted(bytes32 indexed answer);
    event WinnerCrowned(address indexed winner, uint256 indexed round);

    // Errors
    error RoundMinDurationNotPassed();
    error NoRoundWinner();
    error FirstRoundNotStarted();
    error UserAlreadyGuessedCorrectly();
    error InvalidProof();

    // Constants and getter functions
    function verifier() external view returns (IVerifier);
    function MIN_ROUND_DURATION() external view returns (uint256);
    function roundStartTime() external view returns (uint256);
    function answer() external view returns (bytes32);
    function currentRoundWinner() external view returns (address);

    // State-changing functions
    function newRound(bytes32 _answer) external;
    function setVerifier(IVerifier _verifier) external;
}
