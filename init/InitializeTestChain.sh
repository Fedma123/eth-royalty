
function get_abs_dir {
  local file="$1"
  echo "$(cd "$(dirname "$1")"; pwd)"
}

customDataDir="$(get_abs_dir $0)""/../CustomDataDir"
customGenesisJson="genesis.json"
keystoreDir="keystore"

if [ ! -f $customGenesisJson ]; then
    echo "Custom genesis file not found!"
    exit 1
fi

if [ ! -d "$keystoreDir" ]; then
    echo "Keystore directory not found. Aborting."
    exit 2
fi

if [ -d "$customDataDir" ]; then
    rm -rd $customDataDir
fi

mkdir $customDataDir
cp -r $keystoreDir $customDataDir

geth --identity "MyTestChain" \
     --rpc \
     --rpcport "8080" \
     --rpccorsdomain "*" \
     --datadir $customDataDir \
     --port "30303" \
     --nodiscover \
     --rpcapi "db,eth,net,web3" \
     --networkid 2018 \
     init $customGenesisJson
