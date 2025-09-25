# Local Testing

# Setup Anvil

using `anvil/Dockerfile`:

`sudo docker build -t anvil .`
`docker run -d --name anvil -p 8545:8545 anvil`
`docker logs anvil` -> To get accounts, chainID, keys, etc.

# Deploy contract with Forge


Initialie forge inside container:
`docker exec -it anvil bash`
`mkdir ofc`
`cd ofc`
`forge init`
`forge install openzeppelin/openzeppelin-contracts`
`exit`

Copy the contract to container:

`docker cp OlneyFansContract.sol anvil:/root/ofs/src`

In container, run:
`forge build`

Deploy with:
```
forge create src/OlneyFansContract.sol:OlneyFansCoin \
  --rpc-url http://127.0.0.1:8545 \
  --private-key <ANVIL_PRIVATE_KEY> \
  --broadcast
```
Note: added `--constructor-args 1000000000000000000000000` to the end for the modified contract, which seems necessary now.

# On Google VPS/VM

In container /root/src/olneyfans-blockchain/

`forge init`

Copy `Contract.sol` to /root/src/olneyfans-blockchain/src/

Install OpenZeppelin

`forge install OpenZeppelin/openzeppelin-contracts`

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

`sudo docker build -t anvil .`
`docker run -d --name anvil -p 8545:8545 anvil`

Set ngrok for testing without hostname

```
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
chmod +x ngrok
```

Tried this isntead: `sudo snap install ngrok`

