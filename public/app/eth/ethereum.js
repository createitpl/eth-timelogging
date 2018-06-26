const Ethereum = require('web3')
const abi = require('./timelogging_abi')

const web3 = new Ethereum(new Ethereum.providers.HttpProvider("http://127.0.0.1:8545"))
const timeloggingContract = web3.eth.contract(abi)
const contractInstance = timeloggingContract.at( process.env.CONTRACT_ADDRESS)

web3.eth.defaultAccount = process.env.WALLET_ADDRESS

try {
    web3.personal.unlockAccount(web3.eth.defaultAccount, "password");
} catch(e) {
    console.log(e);
    return;
}

module.exports = {
    web3: web3,
    contract: contractInstance
}