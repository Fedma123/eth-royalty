# Royalty smart contract

This is a project for royalty management using ethereum blockchain. The project contains some useful scripts for contract deployment on a local test chain as well as the smart contract code, written in Solidity.

## Getting started

### Prerequisites
#### Ubuntu OS
Some components the project depends on (solc) are not supported by other linux distros such as Debian. The project has not been tested on Ubuntu-based distributions.
#### Geth
The project uses geth to interact with the smart contract. The geth version the project is developed on is 1.8.4. You can install geth by following the [geth installation instructions](https://github.com/ethereum/go-ethereum/wiki/Building-Ethereum).
#### Node.js
The project depends on node version v6.11.4 and the following javascript packages:

* web3 0.20.1 
* system-sleep 1.3.6
* readline-sync 1.4.9

You can install them in the *src/* directory located at project root through *npm* since the directory *src/node_modules* is already ignored by git.
#### solc
solc is the Solidity compiler. This smart contract is written using solc version 0.4.23. You can install solc by following the official [solc installation instructions](http://solidity.readthedocs.io/en/v0.4.23/installing-solidity.html).

### Contract deployment

### Usage example
Here's a simple example demonstrating the smart contract interaction through geth console. The ">" prompt symbol refers to the geth console, while "$" to a normal command line.

Before starting this example make sure to start mining, otherwise the transactions involved will not be mined. In order to start mining we can start a geth console and execute this command:

	> miner.start(1)
	true
The account set as coinbase will start mining all transactions. Since the terminal used for mining will become cluttered with mining logs, we can open another one and attach geth to the same node by executing:

	$ geth attach http://localhost:8080

Before executing the command above make sure to *cd* into the *compiled_contracts* directory in order to easily load the contract scripts.

When we initialize our local blockchain with this project's scripts, we start with some accounts with an arbitrary amount of ether preallocated. We choose three of them for this example. Aldo will be the miner (*coinbase*); Carlo has already deployed a Royalty contract, and Bacco wishes to purchase Carlo's royalty. 

	> Aldo = eth.accounts[0]
	"0x5dfe021f45f00ae83b0aa963be44a1310a782fcc"
	> Bacco = eth.accounts[1]
	"0xfe2b768a23948eddd7d7caea55baa31e39045382"
	> Carlo = eth.accounts[2]
	"0xa9a418da22532bd1189ff8be5cdaf3570bf9da43"
	
We load the script so we can conviniently interact with the smart contract through the web3 API.

	> loadScript('Royalty.js')
	true
	
Initially the smart contract deployed by Carlo will have a balance of 0 wei since nobody has purchased his royalty yet.

	> eth.getBalance(Royalty.address)
	0
	
Bacco, initially starts with a balance of 10 ether.

	> eth.getBalance(Bacco)
	10000000000000000000
	
In order to spend his ether Bacco first needs to unlock his account.

	> personal.unlockAccount(Bacco)
	Unlock account 0xfe2b768a23948eddd7d7caea55baa31e39045382
	Passphrase: 
	true
	
Then Bacco checks what's the minimum price for Carlo's royalty.

	> Royalty.minimumPriceWei({from: Bacco})
	9000000000000000
	
This price seems fair to Bacco, but he's not willing to spend any more than that, so he purchases Carlo's royalty at the minimum price.

	> Royalty.Purchase({from: Bacco, value: 9000000000000000})
	"0x1ccbcaaa13204f1c8931655020daddab9817ece337e9755e2cca79940ae0daed"

Now Bacco checks whether the transaction has been mined by using the transaction hash returned by the Purchase function.

	> eth.getTransaction("0x1ccbcaaa13204f1c8931655020daddab9817ece337e9755e2cca79940ae0daed")
	{
	  blockHash: "0x31b45d371a3dab3228889f9d533891e2972b621f6db14179b9673e65f9b34dcc",
	  blockNumber: 340,
	  from: "0xfe2b768a23948eddd7d7caea55baa31e39045382",
	  gas: 90000,
	  gasPrice: 18000000000,
	  hash: "0x1ccbcaaa13204f1c8931655020daddab9817ece337e9755e2cca79940ae0daed",
	  input: "0x49c15bd9",
	  nonce: 0,
	  r: "0x27466a77a58413d310a67a3d2ff700f3d51ee04466680ed0f4ea94aa5387a127",
	  s: "0x6e4c3ebd9761c8477f35486f05eb7051c2bc0d9e981806d9feb378c0505115ff",
	  to: "0xc42b3f402b2d95c9e9b0baacff040a1de64af86c",
	  transactionIndex: 0,
	  v: "0xa95",
	  value: 9000000000000000
	}
The transaction has been mined since it has been included in block number 340! Bacco also wants to check how much the transaction cost, so in order to do that he has to get the amount of gas used.

	> eth.getTransactionReceipt("0x1ccbcaaa13204f1c8931655020daddab9817ece337e9755e2cca79940ae0daed")
	{
	  blockHash: "0x31b45d371a3dab3228889f9d533891e2972b621f6db14179b9673e65f9b34dcc",
	  blockNumber: 340,
	  contractAddress: null,
	  cumulativeGasUsed: 67436,
	  from: "0xfe2b768a23948eddd7d7caea55baa31e39045382",
	  gasUsed: 67436,
	  logs: [],
	  logsBloom: "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	  root: "0xf2877a30d93b1d45ff7808e399c199761518ac750dfbee9371113f058e590bdd",
	  to: "0xc42b3f402b2d95c9e9b0baacff040a1de64af86c",
	  transactionHash: "0x1ccbcaaa13204f1c8931655020daddab9817ece337e9755e2cca79940ae0daed",
	  transactionIndex: 0
	}

The transaction used 67436 gas and Bacco set the gasPrice to the default value of 18000000000, so the transaction itself cost:

	> web3.fromWei(67436 * 18000000000, 'ether')
	"0.001213848"
which is around 0.67 euros by April 2018.
So when Bacco checks his balance he finds out that he has spent the amount due to Carlo plus the transaction cost.

	> eth.getBalance(Bacco)
	9989786152000000000
	> 10000000000000000000 - 9000000000000000 - 67436 * 18000000000
	9989786152000000000
	
Now both Bacco and Carlo can check that the amount of ether has been succesfully transfered from Bacco's account to the Royalty account.

	> eth.getBalance(Royalty.address)
	9000000000000000

Anybody can inspect whether some account has already payed the royalty, so Bacco checks he's been successfully added among the payers.

	> Royalty.HasAlreadyPayed(Bacco, {from: Bacco})
	true

Bacco is also curious about knowing whether Aldo has also purchased the royalty.

	> Royalty.HasAlreadyPayed(Aldo, {from: Bacco})
	false
	
Now Carlo can withdraw all of his Royalty balance.

	> personal.unlockAccount(Carlo)
	Unlock account 0xa9a418da22532bd1189ff8be5cdaf3570bf9da43
	Passphrase: 
	true
	> eth.getBalance(Carlo)
	19980673508000000000
	> Royalty.Withdraw({from: Carlo})
	"0xf1ef11f59759431ad2498c2ad6be2ed077c8248478119482112962aaac21dcf3"
	> eth.getBalance(Carlo)
	19989137036000000000
	
Again some ether of Carlo's account have been used to pay for the transaction.
Carlo can now check that he's withdrawn all his Royalty balance.

	> eth.getBalance(Royalty.address)
	0


## Description

### Summary
* One smart contract per resource
* Resource identified by its hash
* One paying method supported: pay at least minimum price
* Timestamped contract creation

### Rationale
This smart contract is intended to provide a way to pay for royalties in a decetralized manner, bypassing any third parties and connecting directly creator and customer. Another useful benefit this smart contract provides, is a way to determine, in case of a dispute, the exact timestamp the *resource* was committed to the blockchain, thus proving the owner's effective ownership of the *resource*. By the term *resource* we mean the entity (song, paper, photo, movie ...) subject to royalties.

For this smart contract first version, only one method of payment is supported: setting a minimum price. The customer is free to pay more than the minimum price. Once the cutomer has payed, the royalty will be valid forever. This method of royalty payment is inspired by a similar method of payment adopted by emerging musical artists: the artist sets a minimum entry price for each song/album and then his fans decide whether he deserves more.

The *resource* if not already available in digital form, needs to be converted in digital format, so that the owner is able to compute its hash (for example SHA256). The owner sets the *resource* minimum price, he decides the resource name and then he is able to create the smart contract. The owner then can publish the smart contract address to let everybody know where to pay for the royalty. He may publish the address on social media, on his company website, or expose a QR code in front of the stage.

Remember that only the resource hash is stored inside the contract, not the resource itself. It's the owner responsibility not to loose the original version of the resource that originated the hash. For example photographers must securely store .RAW files of their photos, as well as musicians the .WAV files of their songs.