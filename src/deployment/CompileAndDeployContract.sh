##############################################
# Script for smart contract compilation and  #
# deployment on local blockchain             #
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
resourceName="img.jpeg"
resourceHash="0xd8752fc4a6e944ef5341f7a155637c520bb09968571ce978de7bae951cbfc9de"
resourceMinPrice="9000000000000000" #almost 5 euros as of 19/04/18

while getopts ":s:p:w:n:h:d" opt; do
  case ${opt} in
    s )
      sender="$OPTARG"
      ;;
    w )
      password="$OPTARG"
      ;;
    d )
      deploy="false"
      ;;
    p )
      if [[ $OPTARG =~ ^[0-9]+$ ]]; then
          resourceMinPrice=$OPTARG
      else
          echo "p (minPrice) must be unsigned integer"
          exit 1
      fi
      ;;
    h )
      resourceHash="$OPTARG"
      ;;
    n )
      resourceName="$OPTARG"
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
  scriptDirectory="$(get_abs_dir $0)"
  node "$scriptDirectory"/deployContract.js "$contractAbsoluteFileName" $sender $password $resourceHash $resourceName $resourceMinPrice

  deploymentStatus=$?

  if [ $deploymentStatus -ne 0 ]; then
    exit 1
  fi

  declare -a lines

  while read line; do
    lines+=($line)
  done < "$compileTargetDirectory"/tmp_deploy_result.txt

  contractAddress=${lines[0]}
  #transactionHash=${lines[1]}

  command="var "$contractName"RawAbi='$abi'; "
  command+="var "$contractName"Abi=eth.contract(JSON.parse("$contractName"RawAbi)); "
  command+="var "$contractName"="$contractName"Abi.at(\"$contractAddress\"); "
  echo "$command" > "$compileTargetDirectory"/"$contractName".js

  echo "Generated "$contractName".js. To use your contract load this script in geth."

  rm "$compileTargetDirectory"/tmp_deploy_result.txt

else 
  echo "Contract deployment skipped."
fi

