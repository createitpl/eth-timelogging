// Copyright 2017 https://tokenmarket.net - MIT licensed
'use strict'

let fs = require("fs")
const Ethereum = require('web3')

const web3 = new Ethereum(new Ethereum.providers.HttpProvider("http://127.0.0.1:8545"))

let source = fs.readFileSync("contracts.json")
let contracts = JSON.parse(source)["contracts"]

// ABI description as JSON structure
let abi = JSON.parse(contracts.TimeLogging.abi)
// Smart contract EVM bytecode as hex
let code = '0x' + contracts.TimeLogging.bin

// Create Contract proxy class
let TimeLogging = web3.eth.contract(abi)

try {
    web3.personal.unlockAccount(web3.eth.accounts[0], "password");
} catch(e) {
    console.log(e);
    return;
}

console.log("Deploying the contract");
let contract = TimeLogging.new({from: web3.eth.accounts[0], gas: 1000000, data: code});

// Transaction has entered to geth memory pool
console.log("Your contract is being deployed in transaction at http://rinkeby.etherscan.io/tx/" + contract.transactionHash);

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// We need to wait until any miner has included the transaction
// in a block to get the address of the contract
async function waitBlock() {
    while (true) {
        let receipt = web3.eth.getTransactionReceipt(contract.transactionHash);
        if (receipt && receipt.contractAddress) {
            console.log("Your contract has been deployed at http://rinkeby.etherscan.io/address/" + receipt.contractAddress);
            console.log("Note that it might take 30 - 90 sceonds for the block to propagate befor it's visible in etherscan.io");
            break;
        }
        console.log("Waiting a mined block to include your contract... currently in block " + web3.eth.blockNumber);
        await sleep(4000);
    }
}

waitBlock();