# ZK Panagram


- Each answer is a round
- Only the owner can start a new round
- A round has a minimum duration
- There needs to be a winner to start a new round
- The contract will be an ERC-1155 token contract
   - Token id 0 for winners and token id 1 for runners up
   - Mint id 0 for the first player to answer correctly
   - Mint id 1 for everyone else who answered correctly
- To check if a player's answer is correct, the proof will be checked with the Verifier contract