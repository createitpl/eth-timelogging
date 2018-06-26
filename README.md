`git clone https://gitlab.createit.pl:8888/g.dabrowski/eth-timelogging.git eth_timelogging`

`cd eth_timelogging`

`vagrant up`

`vagrant ssh`

### start the ethereum node:

`geth --rinkeby --light --rpc --rpcapi="db,eth,net,web3,personal,web3"`

##### if command not found:

`sudo apt-get install ethereum`

### in a new console ssh into the vagrant machine:

`cd /var/www/public/`

`npm install`

`pm2 start /var/www/public/time_logging_eth.js`

`sudo env PATH=$PATH:/home/vagrant/.nvm/versions/node/v8.9.4/bin /home/vagrant/.nvm/versions/node/v8.9.4/lib/node_modules/pm2/bin/pm2 startup systemd -u vagrant --hp /home/vagrant`

### create testnet ethereum account

`geth --datadir=$HOME/.ethereum/rinkeby attach ipc:$HOME/.ethereum/rinkeby/geth.ipc console`

`personal.newAccount("password")`

copy the address from `eth.accounts[0]` to the `.env` file in the project root dir under the `WALLET_ADDRESS` key

### follow instructions to get some testnet Ether to the newly created account:

https://gist.github.com/cryptogoth/10a98e8078cfd69f7ca892ddbdcf26bc#gistcomment-2138686

### deploy the contract to the Rinkeby Ethereum Testnet:

`node /var/www/public/contracts/deploy.js`

##### example output:

`Your contract is being deployed in transaction at http://rinkeby.etherscan.io/tx/0x3caa00ba75d42360abb590cc7c56abc3ff9191f4ae938e3cfb7ee788874730c2`

### follow the link in the script output and copy the contract address to the `.env` file:

##### example:

copy `0x17f793297739e58C59AedA339224C832BCfb795C` to `.env` under `CONTRACT_ADDRESS`