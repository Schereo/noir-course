# ZK Mixer

- Users can deposit ETH into the mixer to break the link between deposits and withdrawals.
- Withdraw: User will be able to withdraw by proving their deposit with a ZK proof, generated off-chain by our Noir circuits.
- For privacy reasons, deposits and withdrawals are fixed at 0.001 ETH.

## Proof
- The commitment needs to be calculated from the secret and nullifier.
- We need to check that the commitment is present in the Merkle tree.
We need:
  - Merkle root
  - Merkle leave
- Check that the nullifier matches the public nullifier hash.

### Private inputs
- Secret
- Nullifier
- Merkle proof (path to the leaf in the Merkle tree)
- Boolean indicating whether the node is the left or right child in the Merkle tree.

### Public inputs
- Merkle root
- Merkle leaf
- Public nullifier hash