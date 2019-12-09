# city-hall-solidity


#    Install libs : ethereum (Geth), git

### Install all dependencies (Etherium)
```
sudo apt -y upgrade
sudo apt -y update
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get -y install ethereum
sudo apt-get -y install git
sudo apt-get -y install solc
sudo apt-get -y install wget
sudo apt-get -y install unzip
```


#    Init blockchain

### Create the genesis file
```
mkdir -p ~/blockchain/private-blockchain
cd ~/blockchain/private-blockchain
cat <<EOF > genesis.json
{
"config":{},
"nonce": "0x0000000000220042",
"timestamp": "0x0",
"parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
"extraData": "0x00",
"gasLimit": "0x8000000",
"difficulty": "0x400",
"mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
"coinbase": "0x3333333333333333333333333333333333333333",
"alloc": {}
}
EOF
```

### Start the private blockchain
```
geth --datadir private-chain init genesis.json
geth --port 3000 --networkid 52817 --nodiscover --datadir="private-chain" --maxpeers=0 --rpc --rpcport 8545 --rpcaddr 127.0.0.1 --rpccorsdomain "*" --rpcapi "eth,net,web3"
```
### Create the first account
```
#NEW WINDOWS#
geth attach ipc:~/blockchain/private-blockchain/private-chain/geth.ipc
personal.newAccount(‘password’)
#CLOSE WINDOW#
```
### Launch the blockchain again
```
geth --port 3020 --networkid 52817 --nodiscover --datadir="privateBlockchain" --maxpeers=0 --ipcpath $HOME/.ethereum/geth.ipc
```

### Start the launcher (wallet)
```
wget https://github.com/ethereum/mist/releases/download/v0.11.1/Ethereum-Wallet-linux64-0-11-1.zip
mkdir ethereum-wallet
cd ethereum-wallet
unzip ../Ethereum-Wallet-linux64-0-11-1.zip
./ethereumwallet
```
**Inside the wallet you can upload the contracts**
**Do not forget to mine some coins before**
