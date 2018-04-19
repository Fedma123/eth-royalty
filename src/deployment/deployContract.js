#!/usr/bin/env node

//Script reated for web3 PI version 0.20.1. In version 1.0.0 many things have changed
//such as the property web3.eth.coinbase which has been substituted in
//favor of web3.eth.getCoinbase()
//
//Pay A LOT of attention at documentation versions


const Web3 = require('web3');
var web3_http_endpoint = "http://localhost:8080"
const web3 = new Web3(new Web3.providers.HttpProvider(web3_http_endpoint));
const fs = require('fs');

const ReturnCodes = {
    OK: 0,
    NOT_DEPLOYED: 1,
    ERROR: 2
}


function is_mining() {
    var result = false;

    try {
        result = web3.eth.mining;
    } catch (error) {
        
    }

    return result;
}


function deploy(contract_file_name, sender, password, wait_for_deployment) {        

    const abi_extension = '.abi';
    const bin_extension = '.bin';
    const sol_extension = '.sol';
    
    var path = require('path');
    const contract_absolute_path = path.resolve(contract_file_name);
    const contract_base_name = path.basename(contract_absolute_path);
    const contract_base_path = contract_absolute_path.replace(contract_base_name, '');

    if (contract_absolute_path.includes(sol_extension))
        var contract_base_name_without_extension = contract_base_name.replace(sol_extension, '');    
    else
        var contract_base_name_without_extension = contract_base_name;    
        
    const abi_filename = contract_base_path + 'compiled_contracts/' + contract_base_name_without_extension + abi_extension;
    const bin_filename = contract_base_path + 'compiled_contracts/' + contract_base_name_without_extension + bin_extension;
    const tmp_result_filename = contract_base_path + 'compiled_contracts/' + 'tmp_deploy_result.txt';    

    try {
        var abi = fs.readFileSync(abi_filename, 'utf8');
        var bin = '0x' + fs.readFileSync(bin_filename, 'utf8')        
    } catch (error) {
        console.log(error.message);
        return 1;
    }

    try {
        var unlocked = web3.personal.unlockAccount(sender, password);
    } catch (error) {
        var msg = error.message;

        if (error.message.includes('address'))
            msg += ' \"' + sender + '\"';
        
        if (error.message.includes('passphrase'))
            msg += ' \"' + password + '\"';
         
        console.log(msg);
        return 1;
    }
    
    var contract_abi = web3.eth.contract(JSON.parse(abi));
    var deploy_transaction_object = { from: sender, data: bin, gas: 1000000 };

    var hc_resource_hash = 0xd8752fc4a6e944ef5341f7a155637c520bb09968571ce978de7bae951cbfc9de;
    var hc_resource_name = "img.jpg";
    var hc_resource_min_price = 500000000000000000;

    try {            
        if (wait_for_deployment){
            const max_poll_cycles = 10;
            
            var contract = contract_abi.new(hc_resource_hash, hc_resource_name, hc_resource_min_price, deploy_transaction_object);
            var contract_address = "";
            var sleep = require('system-sleep');

            for(var poll_cycle = 0; poll_cycle < max_poll_cycles; poll_cycle++)
            {
                var tx_receipt = web3.eth.getTransactionReceipt(contract.transactionHash);
                
                if (tx_receipt) {
                    contract_address = tx_receipt.contractAddress;
                    break;
                }

                sleep(3000);
                console.log("Waiting for contrat to be mined...");
            }

            if (contract_address == "")
            {
                console.log("Contract not mined yet. TX_Hash: " + contract.transactionHash);
                return 2;
            } 
            else
            {
                fs.writeFileSync(tmp_result_filename, contract_address + '\n');
                console.log('Contract mined! address: ' + contract_address + ' transactionHash: ' + contract.transactionHash);
            } 
        }
            
        else{
            contract_abi.new(deploy_transaction_object);
            console.log('Submitted contract creation');
        }
               
    } catch (error) {
        console.log(error.message);
        return 1;
    }

    return 0;
}

function get_usage()
{
    return 'Usage: node filename sender password';
}

if (process.argv.length != 5) {
    console.log(get_usage());
    process.exit(1);
}

var mining_answer = '';
var readlineSync = require('readline-sync');
var mining = is_mining();
 
if (mining)
    mining_answer = 'y';

while(!mining && mining_answer == '')
{    
    var question_text = 'It looks like your local instance is not mining.\n';
    question_text +=  'Would you like to deploy the contract anyway? Press enter to retry. (y, n) : ';
    const valid_answers = ['y', 'n'];
    var answer = readlineSync.question(question_text);

    if (valid_answers.includes(answer))
        mining_answer = answer;

    mining = is_mining();
}

if (mining_answer != 'n') {
    console.log('Deployment started.');
    var deploy_result = deploy(process.argv[2], process.argv[3], process.argv[4], mining);
}
else
    console.log('Deployment skipped.');

console.log('Finished.');

var return_code = ReturnCodes.OK;

if (deploy_result == 1)
    return_code = ReturnCodes.ERROR;
else if (!mining || deploy_result == 2)
    return_code = ReturnCodes.NOT_DEPLOYED;

process.exit(return_code);