#!/usr/bin/env node

//Script creato per la versione 0.20.1 dell'API web3
//perché la versione locale di geth ha correntemente questa versione.
//Nella versione 1.0.0 dell'API sono cambiate molte cose; per esempio
//la proprietà web3.eth.coinbase è stata sostituita con web3.eth.getCoinbase()

//Fare MOLTA attenzione alla versione a cui fa riferimento la documentazione online

const Web3 = require('web3');
var web3_http_endpoint = "http://localhost:8080"
const web3 = new Web3(new Web3.providers.HttpProvider(web3_http_endpoint));
const fs = require('fs');

const ReturnCodes = {
    OK: 0,
    NOT_DEPLOYED: 1,
    ERROR: 2
}


//Lanciare lo script da node passando come primo argomento il nome del contratto
//compilato, il mittente del contratto e la password per sbloccare l'account mittente.
//Il contratto NON viene ribloccato dopo il deploy.

const tmp_result_filename = "tmp_deploy_result.txt"

function is_mining() {
    var result = false;

    try {
        result = web3.eth.mining;
    } catch (error) {
        
    }

    return result;
}

// Se la fuzione incontra un qualsiasi errore ritorna 1, 0 altrimenti.
function deploy(contract_file_name, sender, password, wait_for_deployment) {        

    const abi_extension = '.abi';
    const bin_extension = '.bin';
    const abi_filename = contract_file_name + abi_extension;
    const bin_filename = contract_file_name + bin_extension;

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

    try {            
        if (wait_for_deployment)
            contract_abi.new(deploy_transaction_object, deployed);
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

function deployed (e, contract){
    //console.log(e, contract);
    if (typeof contract.address !== 'undefined') {
        var result_data = contract.address + "\n" + contract.transactionHash;
    
        fs.writeFile(tmp_result_filename, result_data);

        console.log('Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
    }
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
else if (!mining)
    return_code = ReturnCodes.NOT_DEPLOYED;

process.exit(return_code);