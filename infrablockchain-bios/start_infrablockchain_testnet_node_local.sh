#!/usr/bin/env zsh
# chmod +x ./start_infrablockchain_testnet_node_local.sh

setopt shwordsplit

export INFRA_NODE_BIN_NAME=infra-node
export INFRA_CLI_BIN_NAME=infra-cli
export INFRA_KEYCHAIN_BIN_NAME=infra-keychain

export INFRABLOCKCHAIN_HOME=/Users/bwlim/Documents/__InfraBlockchain__/infrablockchain-2-git

export INFRA_NODE=$INFRABLOCKCHAIN_HOME/build/bin/$INFRA_NODE_BIN_NAME
export INFRA_NODE_LOG_FILE=/Users/bwlim/Documents/__InfraBlockchain__/infrablockchain_local_testnet_data/log/$INFRA_NODE_BIN_NAME.log

export INFRA_CLI=($INFRABLOCKCHAIN_HOME/build/bin/$INFRA_CLI_BIN_NAME --wallet-url http://127.0.0.1:8900/)
export INFRA_KEYCHAIN=$INFRABLOCKCHAIN_HOME/build/bin/$INFRA_KEYCHAIN_BIN_NAME
export INFRA_KEYCHAIN_LOG_FILE=/Users/bwlim/Documents/__InfraBlockchain__/infrablockchain_local_testnet_data/log/$INFRA_KEYCHAIN_BIN_NAME.log
export INFRABLOCKCHAIN_DEV_WALLET_DIR=/Users/bwlim/Documents/__InfraBlockchain__/infrablockchain_local_testnet_data/infrablockchain_dev_wallet
export INFRA_KEYCHAIN_WALLET_PASSWORD=PW5JcN2AfwXxAV12W1mofb7pbeyJEwwie4JsCaTZvMx5kt38P8TP1
export INFRA_KEYCHAIN_WALLET_NAME=local-testnet

export INFRA_NODE_CONFIG=$INFRABLOCKCHAIN_HOME/infrablockchain-bios/config/config_infrablockchain_local_testnet.ini
export INFRA_NODE_GENESIS_JSON=$INFRABLOCKCHAIN_HOME/infrablockchain-bios/config/genesis_infrablockchain_local_testnet.json
export INFRA_NODE_DATA_DIR=/Users/bwlim/Documents/__InfraBlockchain__/infrablockchain_local_testnet_data/infra_node_data

export INFRABLOCKCHAIN_CONTRACTS_DIR=/Users/bwlim/Documents/__InfraBlockchain__/infrablockchain.contracts-git/build/contracts

export SYS_ACCOUNT=eosio

export INFRA_NODE_API_ENDPOINT=http://127.0.0.1:8888

{ set +x; } 2>/dev/null
red=`tput setaf 1`
green=`tput setaf 2`
magenta=`tput setaf 6`
reset=`tput sgr0`
set -x

{ set +x; } 2>/dev/null
echo "${red}[(Re)Starting INFRABLOCKCHAIN Local Testnet]${reset}"
echo
echo "${green}INFRABLOCKCHAIN_HOME${reset}=${red}$INFRABLOCKCHAIN_HOME${reset}"
echo "${green}INFRA_NODE${reset}=${red}$INFRA_NODE${reset}"
echo "${green}INFRA_NODE_LOG_FILE${reset}=${red}$INFRA_NODE_LOG_FILE${reset}"
echo "${green}INFRA_CLI${reset}=${red}$INFRA_CLI${reset}"
echo "${green}INFRA_CLI_TESTNET${reset}=${red}$INFRA_CLI_TESTNET${reset}"
echo "${green}INFRA_KEYCHAIN${reset}=${red}$INFRA_KEYCHAIN${reset}"
echo "${green}INFRA_KEYCHAIN_LOG_FILE${reset}=${red}$INFRA_KEYCHAIN_LOG_FILE${reset}"
echo "${green}INFRA_KEYCHAIN_WALLET_PASSWORD${reset}=${red}$INFRA_KEYCHAIN_WALLET_PASSWORD${reset}"
echo "${green}INFRA_NODE_CONFIG${reset}=${red}$INFRA_NODE_CONFIG${reset}"
echo "${green}INFRA_NODE_GENESIS_JSON${reset}=${red}$INFRA_NODE_GENESIS_JSON${reset}"
echo "${green}INFRA_NODE_DATA_DIR${reset}=${red}$INFRA_NODE_DATA_DIR${reset}"
echo "${green}INFRABLOCKCHAIN_DEV_WALLET_DIR${reset}=${red}$INFRABLOCKCHAIN_DEV_WALLET_DIR${reset}"
echo "${green}INFRABLOCKCHAIN_CONTRACTS_DIR${reset}=${red}$INFRABLOCKCHAIN_CONTRACTS_DIR${reset}"
echo "${green}SYS_ACCOUNT${reset}=${red}$SYS_ACCOUNT${reset}"
echo "${green}INFRA_NODE_API_ENDPOINT${reset}=${red}INFRA_NODE_API_ENDPOINT${reset}"
echo
set -x

{ set +x; } 2>/dev/null
echo "${red}Ready to (re)start InfraBlockchain Testnet node?${reset}"
echo "write YES to proceed stop process."
read USER_CONFIRM_TO_PROCEED
if [ "$USER_CONFIRM_TO_PROCEED" != "YES" ]; then
  exit 1
fi
set -x

print_section_title() {
  { set +x; } 2>/dev/null
  echo
  echo "${green}[$1]${reset}"
  echo
  set -x
}

{ print_section_title "Stop infra-node"; } 2>/dev/null

pgrep $INFRA_NODE_BIN_NAME
pkill -SIGINT $INFRA_NODE_BIN_NAME
sleep 2
tail $INFRA_NODE_LOG_FILE


{ print_section_title "Stop key daemon"; } 2>/dev/null

pgrep $INFRA_KEYCHAIN_BIN_NAME
pkill -SIGINT $INFRA_KEYCHAIN_BIN_NAME
sleep 5
tail $INFRA_KEYCHAIN_LOG_FILE


{ print_section_title "Start key daemon"; } 2>/dev/null

nohup $INFRA_KEYCHAIN --unlock-timeout 999999999 --http-server-address 127.0.0.1:8900 --wallet-dir $INFRABLOCKCHAIN_DEV_WALLET_DIR > $INFRA_KEYCHAIN_LOG_FILE 2>&1&
sleep 2
$INFRA_CLI wallet open
$INFRA_CLI wallet unlock --password $INFRA_KEYCHAIN_WALLET_PASSWORD
tail $INFRA_KEYCHAIN_LOG_FILE

{ print_section_title "Start infra-node"; } 2>/dev/null

nohup $INFRA_NODE --config $INFRA_NODE_CONFIG --data-dir $INFRA_NODE_DATA_DIR --disable-replay-opts > $INFRA_NODE_LOG_FILE 2>&1&
sleep 10
tail $INFRA_NODE_LOG_FILE

{ set +x; } 2>/dev/null