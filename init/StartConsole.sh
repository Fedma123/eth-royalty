
function get_abs_dir {
  local file="$1"
  echo "$(cd "$(dirname "$1")"; pwd)"
}

datadir="$(get_abs_dir $0)""/../CustomDataDir"

if [ $# -gt 0 ]; then
    datadir="$1"
fi

if [ ! -d "$datadir" ]; then
    echo "Data directory $datadir does not exist."
    exit 1
fi

geth --identity "MyTestChain" \
     --rpc \
     --rpcport "8080" \
     --rpccorsdomain "*" \
     --datadir "$datadir" \
     --port "30303" \
     --nodiscover \
     --rpcapi "db,eth,net,web3,admin,personal,miner,rpc,txpool" \
     --networkid 2018 \
     console
