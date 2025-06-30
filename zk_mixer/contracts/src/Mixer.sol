//SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import {IncrementalMerkleTree, Poseidon2} from "./IncrementalMerkleTree.sol";
import {IVerifier} from "./Verifier.sol";

contract Mixer is IncrementalMerkleTree {
    IVerifier public immutable verifier;
    uint256 public constant DEPOSIT_AMOUNT = 0.001 ether;

    mapping(bytes32 commitments => bool used) public usedCommitments;
    mapping(bytes32 nullifierHashes => bool used) public nullifierHashes;

    // Events
    event Deposit(bytes32 indexed commitment, uint32 insertedIndex, uint256 timestamp);
    event Withdrawal(address indexed recipient, bytes32 nullifierHash, uint256 timestamp);

    // Errors
    error CommitmentAlreadyUsed();
    error InvalidDepositAmount();
    error InvalidProofRoot(bytes32 root);
    error NullifierAlreadyUsed(bytes32 nullifierHash);
    error TransferFailed();
    error InvalidProof();

    constructor(
        IVerifier _verifier,
        uint8 _treeDepth,
        Poseidon2 _hasher
    ) IncrementalMerkleTree(_treeDepth, _hasher) {
        verifier = _verifier;
    }

    /// @notice Deposits ETH into the mixer.
    /// @param _commitment the poseidon commitment of the nullifier and secret (generate off-chain)
    function deposit(bytes32 _commitment) external payable {
        // Check whether the commitment was already used
        require(!usedCommitments[_commitment], CommitmentAlreadyUsed());
        // Check if the the value is the fixed amount defined
        require(msg.value == DEPOSIT_AMOUNT, InvalidDepositAmount());
        // Add the commitment to the incremental merkle tree
        uint32 insertedIndex = _insert(_commitment);
        usedCommitments[_commitment] = true;
        emit Deposit(_commitment, insertedIndex, block.timestamp);
    }

    /// @notice Withdraw ETH from the mixer in a privacy-preserving way.
    /// @param _proof the proof which proves the user's right to withdraw
    function withdraw(
        bytes calldata _proof,
        bytes32 _root,
        bytes32 _nullifierHash,
        address _recipient
    ) external {
        // Check that the root from the proof matches the root on-chain
        require(isKnownRoot(_root), InvalidProofRoot(_root));
        // Check that the nullifier was not used before
        require(
            !nullifierHashes[_nullifierHash],
            NullifierAlreadyUsed(_nullifierHash)
        );
        bytes32[] memory publicInputs = new bytes32[](3);
        publicInputs[0] = _root; 
        publicInputs[1] = _nullifierHash;
        publicInputs[2] = bytes32(uint256(uint160(_recipient))); // Convert recipient

        // Verify the proof
        bool valid = verifier.verify(_proof, publicInputs);
        require(valid, InvalidProof());

        // Transfer the ETH to the user
        nullifierHashes[_nullifierHash] = true;
        (bool success, ) = payable(_recipient).call{value: DEPOSIT_AMOUNT}("");
        require(success, TransferFailed());

        emit Withdrawal(_recipient, _nullifierHash, block.timestamp);
    }
}
