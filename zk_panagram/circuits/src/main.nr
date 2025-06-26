use dep::keccak256;
// Issue at the moment: Users could pass the public answer_hash as their guess_hash to create a valid 
// proof without knowing the correct answer.
// Solution: Hash the answer_hash twice and hash the guess_hash a second time in the circuit so the correct guess_hash cannot be known before.

fn main(guess_hash: Field, answer_double_hash: pub Field, address: pub Field) {

    let guess_hash_decomposed: [u8; 32] = guess_hash.to_be_bytes();
    let guess_double_hash_decomposed: [u8; 32] = keccak256::keccak256(guess_hash_decomposed, 32);

    assert(Field::from_be_bytes(guess_double_hash_decomposed) == answer_double_hash, "Guess does not match the answer hash");
}