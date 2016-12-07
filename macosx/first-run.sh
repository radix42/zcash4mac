#!/bin/bash

# this script MUST be run before launching zcashd for the first time
mkdir -p ~/Library/Application\ Support/Zcash
echo "addnode=mainnet.z.cash" > ~/Library/Application\ Support/Zcash/zcash.conf
echo "rpcuser=username" >> ~/Library/Application\ Support/Zcash/zcash.conf
echo "rpcpassword=`head -c 32 /dev/urandom | base64`" >> ~/Library/Application\ Support/Zcash/zcash.conf
echo "daemon=1" >> ~/Library/Application\ Support/Zcash/zcash.conf
echo "showmetrics=0" >> ~/Library/Application\ Support/Zcash/zcash.conf