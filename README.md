In container /root/src/olneyfans-blockchain/

`forge init`

Copy `Contract.sol` to /root/src/olneyfans-blockchain/src/

`forge build`

Then run:

`forge create --rpc-url http://127.0.0.1:8545 --private-key <PRIVATE_KEY> --broadcast src/OlneyFansContract.sol:OlneyFansCoin`

Made VM at Google Cloud

olneyfans-blockchain

Installed gcloud locally.

Select project and login to vm:
`gcloud projects list`
`gcloud config set project moonlit-order-470703-c8`
`gcloud compute ssh olneyfans-blockchain`

Set firewall:
```
gcloud compute firewall-rules create allow-anvil \
  --allow=tcp:8545 \
  --target-tags=anvil-node \
  --description="Allow Anvil JSON-RPC" \
  --direction=INGRESS
```

Copy over files:

`gcloud compute scp --recurse Dockerfile OlneyFansContract.sol olneyfans-blockchain:~/`

Put them in a new directory in /home and build:
(had previously installe docker)

`sudo docker build -t olneyfans-anvil .`


