-include .env

build: forge build

deploy-local: forge script script/DeployNftAgain.s.sol --rpc-url $http://127.0.0.1:8545 --private-key $(nftAgainPrivateKey2) --broadcast