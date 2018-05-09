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

You can install them in the *src/* directory located at project root through *npm* since the directory *src/node_modules/* is already ignored by git.
#### solc
solc is the Solidity compiler. This smart contract is written using solc version 0.4.23. You can install solc by following the official [solc installation instructions](http://solidity.readthedocs.io/en/v0.4.23/installing-solidity.html).


### Local blockchain
#### Initialization
If you are just starting out, or you want to completely reset an existing instance of your local blockchain, you should execute the script *InitializeTestChain.sh* located in the *init/* directory. This script will delete any preexisting blockchain and create a directory called *CustomDataDir* at the root of the project, which will be used to store all local blockchain related data. The script will also provide a set of accounts with some ether preallocated to get you started right away. The command is:

	$ ./init/InitializeTestChain.sh
	
this directory is already ignored by git.
The initialization resources (*keystore/* and *genesis.json*) have been brutally copied from [chafey/ethereum-private-network](https://github.com/chafey/ethereum-private-network). Thanks [chafey](https://github.com/chafey) for having allowed me to save some time.

#### Interaction
Now that you have successfully created your local blockchain, you can interact with it through the geth console. In order to start one, you can execute the script *StartConsole.sh*

	$ ./init/StartConsole.sh

This command opens the main geth console exposing several endpoints so that you can connect to it from another process. This geth console is the one that will be used to display mining logs. Once you start mining it will become unusable due to the continuous flow of log entries, so you should open a new terminal and attach to the main geth console from its HTTP endpoint, which is by default http://localhost:8080. To do that, you can simply execute:

	$ geth attach http://localhost:8080

To start mining, execute this command on the main geth console:

	> miner.start(1)

### Contract deployment
In order to deploy the contract you can use the *CompileAndDeployContract.sh* script located in *src/deployment/*. This script is specifically tailored on the Royalty smart contract in order to simplify its deployment.

#### Sample contract
For demonstration purposes all parameters have a default value in order to provide an example contract to start with. You can deploy the example contract by executing:

	$ ./src/deployment/CompileAndDeployContract.sh src/contracts/Royalty.sol

If you haven't already started mining the script warns you. For easy deployment of the sample contract it's suggested that you start mining before deploying, even if it's not necessary. More on that later.

A sample of the script output may be this:

	Compiling Royalty bin and abi...
	Deploying contract...
	It looks like your local instance is not mining.
	Would you like to deploy the contract anyway? Press enter to retry. (y, n) :
	Deployment started.
	Waiting for contract to be mined...
	Waiting for contract to be mined...
	Contract mined! address: 0x8952e7b945d6a03525dd8eda0e02d5f2f6081304 transactionHash: 0x30843113d2b153d46bbccaf3bc777d9dfc189d6ac9793981796b49c0f46296b4
	Finished.
	Generated Royalty.js. To use your contract load this script in geth.
	
The script generated the script *Royalty.js* in *src/contracts/compiled_contracts/* which, once loaded in geth, automates the creation of javascript variables that allow the interaction with the deployed contract. These variables are:

* RoyaltyRawAbi: a string containing the contract ABI
* RoyaltyAbi: the contract ABI object
* **Royalty**: the actual deployed contract. This is the variable we're going to use to interact with the deployed contract.

For easy loading of the *Royalty.js* script, *cd* into *src/contracts/compiled_contracts/* and then execute:

	$ geth attach http://localhost:8080
Once the geth console has started, execute this command:

	> loadScript('Royalty.js')
	true
Now, all the abovementioned variables have been automatically created for you, and you can start to interact with your contract. More about contract interaction in **Usage example** below.
#### Custom contract

The *CompileAndDeployContract.sh* script lets you specify the following options:

* -s sender 
(the address of the contract owner)
* -w password 
(the sender's account password)
* -d 
(do not deploy)
* -p minimum_price 
(the price must bei in wei)
* -h resource_hash 
(computed with any algorithm)
* -n resource_name
(the resource name)

Let's say we have created the best GIF ever, and now we want to let everybody be able to pay royalties on it.
First we need a way to compute its hash, for example by using the SHA256 algorithm.

	$ sha256sum myFavouriteGif.gif 
	b5b70af6e17ce3c99b570c671dc4060e8827ffc810f9b419530903594153e5ba  myFavouriteGif.gif
	
Then we need to establish the resource minimum price (90000000000000 wei) and name (myFavouriteGif.gif). Once we'done that we're ready to deploy! Let's say we want to deploy our contract with the second account among the default ones. We can get its address with the following command in geth console:

	> eth.accounts[1]
	"0xfe2b768a23948eddd7d7caea55baa31e39045382"

Let's run the following command setting the appropriate options:

	$ src/deployment/CompileAndDeployContract.sh -s 0xfe2b768a23948eddd7d7caea55baa31e39045382 -w iloveethereum -n myFavouriteGif.gif -p 90000000000000 -h 0xb5b70af6e17ce3c99b570c671dc4060e8827ffc810f9b419530903594153e5ba src/contracts/Royalty.sol
	Compiling Royalty bin and abi...
	Deploying contract...
	Deployment started.
	Waiting for contract to be mined...
	Waiting for contract to be mined...
	Contract mined! address: 0x59d01dcbcc58224f21ddf5063a1070a37b29f6ec transactionHash: 0xcd82014f328cf5ef2fe636818340b79b8614cc667febcd17506523619566d63d                                                     
	Finished.
	Generated Royalty.js. To use your contract load this script in geth.
	
#### Manual contract variable creation in geth
If for some reason the contract can't be mined while the *CompileAndDeployContract.sh* script is waiting, or you decide to submit its creation when you're not mining, you can still instantiate the variables created automatically by *Royalty.js* script, but you have to do it "manually". A possible scenario can be the following:

	$ ./src/deployment/CompileAndDeployContract.sh src/contracts/Royalty.sol
	Compiling Royalty bin and abi...
	Deploying contract...
	It looks like your local instance is not mining.
	Would you like to deploy the contract anyway? Press enter to retry. (y, n) : y
	Deployment started.
	Submitted contract creation. TX_Hash: 0xe647968f52cd38e4cc719d0176ca66730cb16d508d8273dc49b7f1d2f7c7160c
	Finished.
	
Once the contract is mined you can get its address (*contractAddress*) with the following command:

	> eth.getTransactionReceipt("<paste your transaction hash here>")
	{
	  blockHash: "0x9982b1ef800ddce1d9f30c555b40afb3d1ad166a46f2ba397d8931de178596f7",
	  blockNumber: 269,
	  contractAddress: "0x0e79d2b4d0dc8a9e4ad8f4196314448f93f7569b",
	  cumulativeGasUsed: 850356,
	  from: "0x5dfe021f45f00ae83b0aa963be44a1310a782fcc",
	  gasUsed: 425178,
	  logs: [],
	  logsBloom: "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	  root: "0x1f5c6648157f034a1aaf23787c0fc7ead79afb91108a95ca44e6014ebd22a66e",
	  to: null,
	  transactionHash: "<your transaction hash>",
	  transactionIndex: 1
	}
where *getTransactionReceipt* accepts as argument the transaction hash that submitted your contract creation. If the contract is not mined yet, the command above will return *null*.

Once you've got the contract address you have to first store the contract ABI in a variable. You can get the contract's ABI in the file *src/contracts/compiled_contracts/Royalty.abi*.

	> RoyaltyRawAbi = '<paste your abi here>'

Remember to **enclose the ABI between single quotes**!
Then you have to parse it and create a contract with that ABI:
	
	> RoyaltyAbi = eth.contract(JSON.parse(RoyaltyRawAbi))

Finally you can create an instance of the Royalty contract:

	> Royalty=RoyaltyAbi.at("<paste your contract address here>")
## Usage example
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
	
We load the script so we can conveniently interact with the smart contract through the web3 API.

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



## Cost estimate
### Introduction
On ethereum everything that exercises any kind of load on the system, being it computational or storage related, has to be paid in order to prevent malicious abuse or inadvertent bugs from damaging the blockchain availability and integrity. Contract code, persistent storage and memory allocation require a finite amount of *gas* to be paid in order to be successfully executed. Every contract has some code associated with it, and that code is bytecode that can be interpreted and executed by the Ethereum Virtual Machine (EVM) on every node. The [Ethereum Yellow Paper](http://gavwood.com/paper.pdf) defines for each opcode of the EVM its assocated gas cost. The amount of gas consumed by any transaction is equal to the sum of gas cost of all computational steps executed to complete the transaction. Every transaction must specify beforehand a finite amount of gas that will constitue the maximum amount of gas the sender is willing to spend for this transaction. The sender can also decide how much a unit of gas will cost for the current transaction. This quantity is called *gasPrice*. A higher gas price means a higher incentive for miners to mine the transaction compared to other transactions with lower *gasPrice*. This is because `gasUsed * gasPrice = transactionCost` for the sender, but that transactionCost is actually a reward for the miner who manages to include this transaction in the next block. Hence our transaction will be mined faster.

### Cost estimate breakdown
The actual cost of a transaction depends on the contract state since it may trigger a branch of execution that returns immediately while, if the state had been different, another more computation intensive branch may have been chosen. For this reason only the most representative cases have been analyzed by executing real transactions against a couple of deployed contracts. Static gas cost estimates [may not be reliable](https://ethereum.stackexchange.com/questions/266/what-are-the-limitations-to-estimategas-and-when-would-its-estimate-be-considera?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa).

In order to get the *cumulativeGasUsed* value for a transaction, we need to retreive the *transaction receipt* once it's mined by invoking the `eth.getTransactionReceipt()` function in geth,  and passing the transaction hash as argument. In order to invoke a contract method with a transaction in geth, we have to first encode the transaction data by invoking the `getData()` function on the method we're interested in. The value returned by `getData()` contains the contract's method to invoke and its arguments if any, all properly [encoded](https://github.com/ethereum/wiki/wiki/Ethereum-Contract-ABI#argument-encoding). Now we can send the transaction from a valid (and unocked!) account to the smart contract address by invoking the `eth.sendTransaction()` function. Here's an example:

	> Royalty.HasAlreadyPayed.getData(eth.accounts[1]) 
	"0x99ba9323000000000000000000000000fe2b768a23948eddd7d7caea55baa31e39045382"
	> eth.sendTransaction({from: eth.accounts[1], to: Royalty.address, data: "0x99ba9323000000000000000000000000fe2b768a23948eddd7d7caea55baa31e39045382"})
	"0x3ecaf14a06fd6de0958e0c20f4df2b7786bed516f75457c7a78d8419d1573627"
	> eth.getTransactionReceipt("0x3ecaf14a06fd6de0958e0c20f4df2b7786bed516f75457c7a78d8419d1573627")
	{
	  blockHash: "0xccd736cddbafb309b42579d0c57f931d86637e1e5d66ea391a3d07d3f9d13c9f",
	  blockNumber: 1366,
	  contractAddress: null,
	  cumulativeGasUsed: 23989,
	  from: "0xfe2b768a23948eddd7d7caea55baa31e39045382",
	  gasUsed: 23989,
	  logs: [],
	  logsBloom: "0x00...00",
	  root: "0xcae07a808b0b0f49cf1d9aa3e00fcaefb2fcc86d601f88823d516e087ebd8e2f",
	  to: "0x444e52b90cb15e54eaae86167ca62b0ebe69589c",
	  transactionHash: "0x3ecaf14a06fd6de0958e0c20f4df2b7786bed516f75457c7a78d8419d1573627",
	  transactionIndex: 0
	}

As you can see, the cumulative gas used for this transaction is: 23989. If we want this transaction to be processed quickly, we can set the *gasPrice* at a high value (e.g. 2 Gwei), while if we don't care about waiting, we can safely set it pretty low (e.g. 0.4 Gwei). 
The gas price estimates were taken, at the moment of writing from [ETH Gas Station](https://ethgasstation.info/):

**Ethereum price** (24th April 2018): **524 €/ETH**

Speed|Gas Price (Gwei)
-------|--------------
SafeLow (less than 30m) | 0.4
Standard (less than 5m)  |   1 
Fast (less than 2m) 	 |  3

By executing transactions against all other contract methods in the same fashion as mentioned above, and with different accounts and arguments, we get the following results.

Method Name|Lowest gas|Safe Low|Standard|Fast|Highest Gas|SafeLow|Standard|Fast
---------|----------|-------|--------|----|-----------|-------|--------|----
constructor|536975 (Name 8 chars long)|€ 0.113|€ 0.281|€ 0.844|579774 (Name 47 chars long)|€ 0.122|€ 0.304|€ 0.911
Purchase|22674 (Account already paid, so this is unusual)|€ 0.005|€ 0.012|€ 0.036|68208 (More frequent: accout never paid)|€ 0.014|€ 0.036|€ 0.107
Withdraw|29804 (Transaction succeeds)|€ 0.006|€ 0.016|€ 0.047|67436 (Transaction fails: not owner)|€ 0.014|€ 0.035|€ 0.106
HasAlreadyPaid|23989|€ 0.005|€ 0.013|€ 0.038|23989|€ 0.005|€ 0.013|€ 0.038
resourceHash|23210|€ 0.005|€ 0.012|€ 0.036|23210|€ 0.005|€ 0.012|€ 0.036
resourceName|22578 (Name 8 chars long)|€ 0.005|€ 0.012|€ 0.035|22991 (Name 47 chars long)|€ 0.005|€ 0.012|€ 0.036
contractMinedTimestamp|21766|€ 0.005|€ 0.011|€ 0.034|21766|€ 0.005|€ 0.011|€ 0.034
minimumPriceWei|21722|€ 0.005|€ 0.011|€ 0.034|21722|€ 0.005|€ 0.011|€ 0.034

In cases where both *Lowest Gas* and *Highest Gas* are the same, no differences in *cumulativeGasUsed* have been found by varying arguments and accounts.

The operational costs found for this smart contract are considered acceptable compared to the typical use case imagined for this smart contract: if the royalty minimum price was set to 0.00095 ETH (almost 5€) the Purchase transaction cost, with a *gasPrice* of 1Gwei and submitted by an account that has never paid, is going to be `0.036€ / 5€ = 0.72%` of the value transferred.

## Description

### Summary
* One smart contract per resource
* Resource identified by its hash
* One paying method supported: pay at least minimum price
* Timestamped contract creation


### Rationale
This smart contract is intended to provide a way to pay for royalties in a decetralized manner, bypassing any third parties and connecting directly creator and customer. Another useful benefit this smart contract provides, is a way to determine, in case of a dispute, the exact timestamp the *resource* was committed to the blockchain, thus proving the owner's effective ownership of the *resource*. By the term *resource* we mean the entity (song, paper, photo, movie ...) subject to royalties.

For this smart contract first version, only one method of payment is supported: setting a minimum price. The customer is free to pay more than the minimum price. Once the cutomer has payed, the royalty will be valid forever. This method of royalty payment is inspired by a similar method of payment adopted by emerging musical artists: the artist sets a minimum entry price for each song/album and then his fans decide whether he deserves more.

The *resource*, if not already available in digital form, needs to be converted in digital format, so that the owner is able to compute its hash (for example SHA256). The owner sets the *resource* minimum price, he decides the resource name and then he is able to create the smart contract. The owner then can publish the smart contract address to let everybody know where to pay for the royalty. He may publish the address on social media, on his company website, or expose a QR code in front of the stage.

Remember that only the resource hash is stored inside the contract, not the resource itself. It's the owner responsibility not to lose the original version of the resource that originated the hash. For example photographers must securely store .RAW files of their photos, as well as musicians the .WAV files of their songs.