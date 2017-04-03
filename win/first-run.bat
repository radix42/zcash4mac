rem this script MUST be run before launching zcashd for the first time
mkdir %AppData%\Zcash
mkdir %LocalAppData%\ZCashSwingWalletUI

@echo off

IF NOT EXIST %AppData%\Zcash\zcash.conf (
   (
    echo addnode=mainnet.z.cash 
    echo rpcuser=username 
    echo rpcpassword=password%random%%random%
    echo daemon=1 
    echo showmetrics=0 
    echo gen=0 
    ) > %AppData%\Zcash\zcash.conf
) 

IF NOT EXIST %LocalAppData%\ZCashSwingWalletUI\addressBook.csv (
   (
    echo t1WjQ6yqv8Yh9pcc2f4JMrMpVJ3LNQXFt3u,zcash4win donations
    echo t1VAggo7RusLVBzHSeYbGkxDQQhLZyigxty,ZCashSwingUI donations
    ) > %LocalAppData%\ZCashSwingWalletUI\addressBook.csv
)
