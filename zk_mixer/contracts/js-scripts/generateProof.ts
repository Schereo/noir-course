import { Barretenberg, Fr, UltraHonkBackend } from '@aztec/bb.js';
import { ethers } from 'ethers';
import { Noir } from '@noir-lang/noir_js';
import path from 'path';
import fs from 'fs';

import { merkleTree } from './merkleTree.js';

const circuit = JSON.parse(
    fs.readFileSync(path.resolve(__dirname, '../../circuits/target/circuits.json'), 'utf8')
);

export default async function generateProof() {
    const bb = await Barretenberg.new();
    const inputs = process.argv.slice(2);
    const nullifier= inputs[0];
    const secret = inputs[1];

    const commitment = await bb.poseidon2Hash([Fr.fromString(nullifier), Fr.fromString(secret)]);    
    const nullifierHash = await bb.poseidon2Hash([Fr.fromString(nullifier)]);

    const _recipient = inputs[2];
    const leaves = inputs.slice(3);
    const tree = await merkleTree(leaves);
    const merkleProof = tree.proof(tree.getIndex(commitment.toString()));
    


    try {
        const noir = new Noir(circuit);
        const honk = new UltraHonkBackend(circuit.bytecode, {threads: 1});
        const input = {
            root: merkleProof.root.toString(),
            nullifier_hash: nullifierHash.toString(),
            _recipient,
            nullifier, 
            secret,
            merkle_proof: merkleProof.pathElements.map((el) => el.toString()),
            is_even: merkleProof.pathIndices.map((el) => el % 2 === 0)
        };
        const logger = console.log;
        console.log = () => {}; // Suppress Noir logs
        const { witness } = await noir.execute(input);
        
        const { proof, publicInputs } = await honk.generateProof(witness, {keccak: true });
        console.log = logger; // Restore console.log
        const result = ethers.AbiCoder.defaultAbiCoder().encode(
            ['bytes', 'bytes32[]'],
            [proof, publicInputs]
        );
        return result;
    } catch (error) {
        console.log('Error generating proof:', error);
        throw error;
    }
}

(async () => {
    generateProof()
        .then((result) => {
            process.stdout.write(result);
            process.exit(0);
        })
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
})();
