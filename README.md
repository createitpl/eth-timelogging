# Time logging with checksums commited to the Ethereum blockchain

## OVERVIEW

A simple app that commits hashed timelogs as a checksum to an Ethereum smart contract.
It leverages the hashpower that goes into mining the public blockchain to provide proof
that time logs remained unchanged after the commiting transaction has been mined.

This demo operates on the https://www.rinkeby.io testnet for Ethereum.

Following the installation steps will have you run an Ethereum node on the testnet and 
deploy your own instance of the smart contract.


## INSTALLATION

`git clone https://gitlab.createit.pl:8888/g.dabrowski/eth-timelogging.git eth_timelogging`

`cd eth_timelogging`

`vagrant up`

`vagrant ssh`

### Start the Ethereum node:

`geth --rinkeby --light --rpc --rpcapi="db,eth,net,web3,personal,web3"`

The node will start syncing with the network. It may take up to a few hours.

##### f command not found:

`sudo apt-get install ethereum`

### In a new console ssh into the vagrant machine:

`cd /var/www/public/`

`npm install`

`pm2 start /var/www/public/time_logging_eth.js`

`sudo env PATH=$PATH:/home/vagrant/.nvm/versions/node/v8.9.4/bin /home/vagrant/.nvm/versions/node/v8.9.4/lib/node_modules/pm2/bin/pm2 startup systemd -u vagrant --hp /home/vagrant`

### Create testnet ethereum account

`geth --datadir=$HOME/.ethereum/rinkeby attach ipc:$HOME/.ethereum/rinkeby/geth.ipc console`

`personal.newAccount("password")`

copy the address from `eth.accounts[0]` to the `.env` file in the project root dir under the `WALLET_ADDRESS` key

### Follow instructions to get some testnet Ether to the newly created account:

https://gist.github.com/cryptogoth/10a98e8078cfd69f7ca892ddbdcf26bc#gistcomment-2138686

### Deploy the contract to the Rinkeby Ethereum Testnet:

`node /var/www/public/contracts/deploy.js`

##### example output:

`Your contract is being deployed in transaction at http://rinkeby.etherscan.io/tx/0x3caa00ba75d42360abb590cc7c56abc3ff9191f4ae938e3cfb7ee788874730c2`

### Follow the link in the script output and copy the contract address to the `.env` file:

##### example:

copy `0x17f793297739e58C59AedA339224C832BCfb795C` to `.env` under `CONTRACT_ADDRESS`


## SIMPLE TESTS

`cd /var/www/public/tests`

Follow the steps in `test_steps.md` for a quick demostration

## API

##### Add a new log to the db:
`POST /logs/new` 

example request body:

all 4 fields are required

`{
 	"user": "test_user1@company.com",
 	"task": "test_task1",
 	"start": 1527354210,
 	"end": 1527355000
}`

##### Commit new logs to the smart contract:

`POST /logs/commit`

##### Verify that the logs commited to the smart contract under the given hash id still remain unchanged in the database

`GET /logs/validate/hashid/:id`