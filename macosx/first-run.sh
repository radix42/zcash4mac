#!/bin/bash

# this script MUST be run before launching zcashd for the first time
mkdir -p ~/Library/Application\ Support/Zcash

CONF=~/Library/Application\ Support/Zcash/zcash.conf
if [ ! -f "${CONF}" ]; then
    echo "addnode=mainnet.z.cash" > "${CONF}"
    echo "rpcuser=username" >> "${CONF}"
    echo "rpcpassword=`head -c 32 /dev/urandom | base64`" >> "${CONF}"
    echo "daemon=1" >> "${CONF}"
    echo "showmetrics=0" >> "${CONF}"
    echo "gen=0" >> "${CONF}"
fi

ADDR=~/Library/Application\ Support/zcash4mac/addressBook.csv
if [ ! -f "${ADDR}" ]; then
    echo "t1WjQ6yqv8Yh9pcc2f4JMrMpVJ3LNQXFt3u,zcash4mac donations" >> "${ADDR}"
    echo "t1VAggo7RusLVBzHSeYbGkxDQQhLZyigxty,ZCashSwingUI donations" >> "${ADDR}"
fi
