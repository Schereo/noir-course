// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import {Mixer} from "../src/Mixer.sol";
import {Test, console} from "forge-std/Test.sol";
import {HonkVerifier} from "../src/Verifier.sol";
import {IncrementalMerkleTree, Poseidon2} from "../src/IncrementalMerkleTree.sol";

contract MixerTest is Test {
    Mixer mixer;
    HonkVerifier verifier;
    Poseidon2 hasher;

    address recipient = makeAddr("recipient");

    function setUp() public {
        hasher = new Poseidon2();
        verifier = new HonkVerifier();
        mixer = new Mixer(verifier, uint8(20), hasher);
    }

    function _getCommitment() private returns (bytes32 _commitment, bytes32 _nullifier, bytes32 _secret) {
        string[] memory inputs = new string[](3);
        inputs[0] = "npx";
        inputs[1] = "tsx";
        inputs[2] = "../contracts/js-scripts/generateCommitment.ts";
        bytes memory result = vm.ffi(inputs);
        // ABI decode results
        (_commitment, _nullifier, _secret) = abi.decode(result, (bytes32, bytes32, bytes32));
    }

    function _getProof(
        bytes32 nullifier,
        bytes32 secret,
        address _recipient,
        bytes32[] memory leaves
    ) private returns (bytes memory proof, bytes32[] memory publicInputs) {
        string[] memory inputs = new string[](6 + leaves.length);
        inputs[0] = "npx";
        inputs[1] = "tsx";
        inputs[2] = "../contracts/js-scripts/generateProof.ts";
        inputs[3] = vm.toString(nullifier);
        inputs[4] = vm.toString(secret);
        inputs[5] = vm.toString(bytes32(uint256(uint160(_recipient))));
        
        for (uint256 i = 0; i < leaves.length; i++) {
            inputs[6 + i] = vm.toString(leaves[i]);
        }

        bytes memory result = vm.ffi(inputs);
        (proof, publicInputs) = abi.decode(result, (bytes, bytes32[]));
    }

    function testMakeDeposit() public {
        (bytes32 _commitment, , )  = _getCommitment();
        console.logBytes32(_commitment);

        vm.expectEmit(true, false, false, true);
        emit Mixer.Deposit(_commitment, 0, block.timestamp);
        mixer.deposit{value: mixer.DEPOSIT_AMOUNT()}(_commitment);
    }

    function testWithdrawal() public {
        // Make deposit first
        (bytes32 _commitment, bytes32 _nullifier, bytes32 _secret) = _getCommitment();
        mixer.deposit{value: mixer.DEPOSIT_AMOUNT()}(_commitment);

        bytes32[] memory leaves = new bytes32[](1);
        leaves[0] = _commitment;
        // Create a proof for withdrawal
        (bytes memory proof, bytes32[] memory publicInputs) = _getProof(_nullifier, _secret, recipient, leaves);
        assertTrue(verifier.verify(proof, publicInputs));

        // Make the withdrawal
        assertEq(recipient.balance, 0);
        assertEq(address(mixer).balance, mixer.DEPOSIT_AMOUNT());
        mixer.withdraw(proof, publicInputs[0], publicInputs[1], address(uint160(uint256(publicInputs[2]))));
        assertEq(recipient.balance, mixer.DEPOSIT_AMOUNT());
        assertEq(address(mixer).balance, 0);
    }
}
