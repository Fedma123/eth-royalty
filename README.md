#Royalty smart contract

This is a project for royalty management using ethereum blockchain. The project contains some useful scripts for contract deployment on a local test chain as well as the smart contract code, written in Solidity.

##Getting started

###Prerequisites
####Ubuntu OS
Some components the project depends on (solc) are not supported by other linux distros such as Debian. The project has not been tested on Ubuntu-based distributions.
####Geth
The project uses geth to interact with the smart contract. The geth version the project is developed on is 1.8.4. You can install geth by following the [installation instructions](https://github.com/ethereum/go-ethereum/wiki/Building-Ethereum).
####Node.js
The project depends on node version v6.11.4 and the following javascript packages:

* web3 0.20.1 
* system-sleep 1.3.6
* readline-sync 1.4.9
####solc
solc is the Solidity compiler. This smart contract is written using solc version 0.4.21

###Contract deployment

##Description

###Summary
* One smart contract per resource
* Resource identified by its hash
* One paying method supported: pay at least minimum price
* Timestamped contract creation

###Rationale
This smart contract is intended to provide a way to pay for royalties in a decetralized manner, bypassing any third parties an connecting directly creator and customer. Another useful benefit this smart contract provides, is a way to determine, in case of a dispute, the exact timestamp the *resource* was committed to the blockchain, thus proving the owner's effective ownership of the *resource*. By the term *resource* we mean the entity (song, paper, photo, movie ...) subject to royalties.

For this smart contract first version only one method of payment is supported: setting a minimum price. The customer is free to pay more than the minimum price. Once the cutomer has payed, the royalty will be valid forever. This method of royalty payment is inspired by a similar method of payment adopted by emerging musical artists: the artist sets a minimum entry price for each song/album and then his fans decide whether he deserves more.

The *resource* if not already available in digital form, needs to be converted in digital format, so that the owner is able to compute its hash (for example SHA256). The owner sets the *resource* minimum price, he decides the resource name and then he is able to create the smart contract. The owner the can publish the smart contract address to let everybody know where to pay for the royalty. He may publish the address on social media, on his company website, or expose a QR code in front of the stage.

Remember that only the resource hash is stored inside the contract, not the resource itself. It's the owner responsibility not to loose the original version of the resource that originated the hash. For example photographers must securely store .RAW files of their photos, as well as musicians the .WAV files of their songs.