use dep::poseidon::poseidon2::Poseidon2;
mod merkle_tree;

fn main(
    // Public inputs
    root: pub Field,
    nullifier_hash: pub Field,
    _recipient: pub Field,
    // Private inputs
    nullifier: Field,
    secret: Field,
    merkle_proof: [Field; 20],
    is_even: [bool; 20]
) {
    // compute the commitment Poseidon(nullifier, secret)
    let commitment: Field = Poseidon2::hash([nullifier, secret], 2);
    // check if provided nullifier hash and computed nullifier hash match
    let computed_nullifier_hash: Field = Poseidon2::hash([nullifier], 1);
    assert(computed_nullifier_hash == nullifier_hash);

    // Recalculate the Merkle root from the commitment and the Merkle proof
    let computed_root: Field = merkle_tree::compute_merkle_root(commitment, merkle_proof, is_even);
    // Check if the computed Merkle root matches the provided root
    assert(computed_root == root, "Computed root does not match the provided root");
}