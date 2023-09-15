This puzzle is the same with `Privacy` puzzle.

We get the instance address: 0x7ce586371a38B2833d84809A84b0d14eFF954581

Then we can use `cast storage` command to check the state variable in this contract
Note that, the `password` is on slot 1

```shell
//  0x412076657279207374726f6e67207365637265742070617373776f7264203a29

    cast storage --rpc-url $GORLI \
--etherscan-api-key $ETHERSCAN_API_KEY \
0x7ce586371a38B2833d84809A84b0d14eFF954581 1
```

We get this 32 bytes back, and we can use this to unlock the `Vault` contract.

```shell
//  0xec9b5b3a412076657279207374726f6e67207365637265742070617373776f7264203a29

cast calldata "unlock(bytes32)" 0x412076657279207374726f6e67207365637265742070617373776f7264203a29
```

Using `cast calldata` generate calldata, then make a raw transaction call.
