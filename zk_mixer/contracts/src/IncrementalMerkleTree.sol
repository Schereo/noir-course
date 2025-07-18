// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import {Poseidon2, Field} from "poseidon2-evm/Poseidon2.sol";

contract IncrementalMerkleTree {
    uint8 public immutable depth;
    Poseidon2 public immutable hasher;
    uint8 public constant ROOT_HISTORY_LENGTH = 30;

    mapping(uint256 index => bytes32 root) public roots;
    uint32 public currentRootIndex;
    uint32 public nextLeafIndex;
    mapping(uint32 depth => bytes32 subtreeHash) public cachedSubtrees;

    // Errors
    error IndexOutOfBounds(uint32 i);
    error InvalidTreeDepth();
    error MerkleTreeFull();

    constructor(uint8 _depth, Poseidon2 _hasher) {
        require(_depth > 0 && _depth <= 32, InvalidTreeDepth());
        depth = _depth;
        hasher = _hasher;
        roots[0] = zeros(_depth);
    }

    function zeros(uint32 i) public pure returns (bytes32) {
        if (i == 0)
            return
                bytes32(
                    0x0d823319708ab99ec915efd4f7e03d11ca1790918e8f04cd14100aceca2aa9ff
                );
        else if (i == 1)
            return
                bytes32(
                    0x170a9598425eb05eb8dc06986c6afc717811e874326a79576c02d338bdf14f13
                );
        else if (i == 2)
            return
                bytes32(
                    0x273b1a40397b618dac2fc66ceb71399a3e1a60341e546e053cbfa5995e824caf
                );
        else if (i == 3)
            return
                bytes32(
                    0x16bf9b1fb2dfa9d88cfb1752d6937a1594d257c2053dff3cb971016bfcffe2a1
                );
        else if (i == 4)
            return
                bytes32(
                    0x1288271e1f93a29fa6e748b7468a77a9b8fc3db6b216ce5fc2601fc3e9bd6b36
                );
        else if (i == 5)
            return
                bytes32(
                    0x1d47548adec1068354d163be4ffa348ca89f079b039c9191378584abd79edeca
                );
        else if (i == 6)
            return
                bytes32(
                    0x0b98a89e6827ef697b8fb2e280a2342d61db1eb5efc229f5f4a77fb333b80bef
                );
        else if (i == 7)
            return
                bytes32(
                    0x231555e37e6b206f43fdcd4d660c47442d76aab1ef552aef6db45f3f9cf2e955
                );
        else if (i == 8)
            return
                bytes32(
                    0x03d0dc8c92e2844abcc5fdefe8cb67d93034de0862943990b09c6b8e3fa27a86
                );
        else if (i == 9)
            return
                bytes32(
                    0x1d51ac275f47f10e592b8e690fd3b28a76106893ac3e60cd7b2a3a443f4e8355
                );
        else if (i == 10)
            return
                bytes32(
                    0x16b671eb844a8e4e463e820e26560357edee4ecfdbf5d7b0a28799911505088d
                );
        else if (i == 11)
            return
                bytes32(
                    0x115ea0c2f132c5914d5bb737af6eed04115a3896f0d65e12e761ca560083da15
                );
        else if (i == 12)
            return
                bytes32(
                    0x139a5b42099806c76efb52da0ec1dde06a836bf6f87ef7ab4bac7d00637e28f0
                );
        else if (i == 13)
            return
                bytes32(
                    0x0804853482335a6533eb6a4ddfc215a08026db413d247a7695e807e38debea8e
                );
        else if (i == 14)
            return
                bytes32(
                    0x2f0b264ab5f5630b591af93d93ec2dfed28eef017b251e40905cdf7983689803
                );
        else if (i == 15)
            return
                bytes32(
                    0x170fc161bf1b9610bf196c173bdae82c4adfd93888dc317f5010822a3ba9ebee
                );
        else if (i == 16)
            return
                bytes32(
                    0x0b2e7665b17622cc0243b6fa35110aa7dd0ee3cc9409650172aa786ca5971439
                );
        else if (i == 17)
            return
                bytes32(
                    0x12d5a033cbeff854c5ba0c5628ac4628104be6ab370699a1b2b4209e518b0ac5
                );
        else if (i == 18)
            return
                bytes32(
                    0x1bc59846eb7eafafc85ba9a99a89562763735322e4255b7c1788a8fe8b90bf5d
                );
        else if (i == 19)
            return
                bytes32(
                    0x1b9421fbd79f6972a348a3dd4721781ec25a5d8d27342942ae00aba80a3904d4
                );
        else if (i == 20)
            return
                bytes32(
                    0x087fde1c4c9c27c347f347083139eee8759179d255ec8381c02298d3d6ccd233
                );
        else if (i == 21)
            return
                bytes32(
                    0x1e26b1884cb500b5e6bbfdeedbdca34b961caf3fa9839ea794bfc7f87d10b3f1
                );
        else if (i == 22)
            return
                bytes32(
                    0x09fc1a538b88bda55a53253c62c153e67e8289729afd9b8bfd3f46f5eecd5a72
                );
        else if (i == 23)
            return
                bytes32(
                    0x14cd0edec3423652211db5210475a230ca4771cd1e45315bcd6ea640f14077e2
                );
        else if (i == 24)
            return
                bytes32(
                    0x1d776a76bc76f4305ef0b0b27a58a9565864fe1b9f2a198e8247b3e599e036ca
                );
        else if (i == 25)
            return
                bytes32(
                    0x1f93e3103fed2d3bd056c3ac49b4a0728578be33595959788fa25514cdb5d42f
                );
        else if (i == 26)
            return
                bytes32(
                    0x138b0576ee7346fb3f6cfb632f92ae206395824b9333a183c15470404c977a3b
                );
        else if (i == 27)
            return
                bytes32(
                    0x0745de8522abfcd24bd50875865592f73a190070b4cb3d8976e3dbff8fdb7f3d
                );
        else if (i == 28)
            return
                bytes32(
                    0x2ffb8c798b9dd2645e9187858cb92a86c86dcd1138f5d610c33df2696f5f6860
                );
        else if (i == 29)
            return
                bytes32(
                    0x2612a1395168260c9999287df0e3c3f1b0d8e008e90cd15941e4c2df08a68a5a
                );
        else if (i == 30)
            return
                bytes32(
                    0x10ebedce66a910039c8edb2cd832d6a9857648ccff5e99b5d08009b44b088edf
                );
        else if (i == 31)
            return
                bytes32(
                    0x213fb841f9de06958cf4403477bdbff7c59d6249daabfee147f853db7c808082
                );
        else revert IndexOutOfBounds(i);
    }

    function isKnownRoot(bytes32 _root) public view returns (bool) {
        if (_root == bytes32(0)) {
            return false; 
        }
        uint32 _currentRootIndex = currentRootIndex;
        for (uint32 i; i < ROOT_HISTORY_LENGTH; i++) {
            if (roots[_currentRootIndex] == _root) {
                return true;
            }
            _currentRootIndex = (_currentRootIndex + ROOT_HISTORY_LENGTH - 1) % ROOT_HISTORY_LENGTH;
        }
        return false;
    }

    function _insert(bytes32 _leaf) internal returns (uint32) {
        uint32 _nextLeafIndex = nextLeafIndex;
        require(_nextLeafIndex < 2 ** depth, MerkleTreeFull());

        uint32 currentIndex = _nextLeafIndex;
        bytes32 currentHash = _leaf;
        bytes32 left;
        bytes32 right;
        for (uint32 i; i < depth; i++) {
            if (currentIndex % 2 == 0) {
                // - if even, the new leaf is the left child and hash it with a zero ("cyfrin") as the sibling node on the right
                // the result needs to be a new cached subtree
                left = currentHash;
                right = zeros(i);
                cachedSubtrees[i] = left;
            } else {
                // - if odd, the new leaf is the right child and hash it with the previous cached subtree (can be a single node if depth := 0) as the sibling node on the left
                left = cachedSubtrees[i];
                right = currentHash;
            }

            currentHash = Field.toBytes32(
                hasher.hash_2(Field.toField(left), Field.toField(right))
            );
            currentIndex = currentIndex / 2;
        }

        // Increment root index modulo ROOT_HISTORY_LENGTH (ring buffer)
        currentRootIndex = (currentRootIndex + 1) % ROOT_HISTORY_LENGTH;
        // Update root
        roots[currentRootIndex] = currentHash;
        nextLeafIndex = _nextLeafIndex + 1;
        return _nextLeafIndex;
    }
}
