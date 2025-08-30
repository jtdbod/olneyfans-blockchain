In container /root/src/olneyfans-blockchain/

`forge init`

Copy `Contract.sol` to /root/src/olneyfans-blockchain/src/

`forge build`

Then run:

`forge create --rpc-url http://127.0.0.1:8545 --private-key <PRIVATE_KEY> --broadcast src/OlneyFansContract.sol:OlneyFansCoin`

