##############################################
# Script per la compilazione ed il deploy    #
# di uno smart contract su blockchain locale #
##############################################


function get_abs_filename {
  local file="$1"
  echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

function get_abs_dir {
  local file="$1"
  echo "$(cd "$(dirname "$1")"; pwd)"
}

sender="0x5dfe021f45f00ae83b0aa963be44a1310a782fcc"
password="iloveethereum"
deploy="true"

while getopts ":s:p:n" opt; do
  case ${opt} in
    s )
      sender="$OPTARG"
      ;;
    p )
      password="$OPTARG"
      ;;
    n )
      deploy="false"
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

if [ $# -ne 1 ]; then
    echo "Expected contract file name as argument."
    exit 1
fi

contractFileName="$1"
contractAbsoluteFileName="$(get_abs_filename "$1")"
contractAbsoluteDir="$(get_abs_dir "$1")"

solExtension=".sol"
contractName="$(basename "$contractAbsoluteFileName")"
contractName=${contractName%.*}

compileTargetDirectory="$contractAbsoluteDir"/"compiled_contracts"

echo "Compiling $contractName bin and abi..."

if [ ! -d "$compileTargetDirectory" ]; then
  mkdir "$compileTargetDirectory"
fi

solc -o "$compileTargetDirectory" --optimize --overwrite --abi --bin "$contractAbsoluteFileName"

if [ $deploy = "true" ]; then
  echo "Deploying contract..."
  abi=$(cat "$compileTargetDirectory"/"$contractName".abi)
  node deployContract.js "$contractName" $sender $password

  deploymentStatus=$?

  if [ $deploymentStatus -ne 0 ]; then
    exit 1
  fi

  declare -a lines

  while read -r line; do
    lines+=($line)
  done <tmp_deploy_result.txt

  contractAddress=${lines[0]}
  transactionHash=${lines[1]}

  command="var "$contractName"RawAbi='$abi'; "
  command+="var "$contractName"Abi=eth.contract(JSON.parse("$contractName"RawAbi)); "
  command+="var "$contractName"="$contractName"Abi.at(\"$contractAddress\"); "
  echo "$command" > "$contractName".js

  echo "Generated "$contractName".js. To use your contract load this script in geth."

  rm tmp_deploy_result.txt

else 
  echo "Contract deployment skipped."
fi

