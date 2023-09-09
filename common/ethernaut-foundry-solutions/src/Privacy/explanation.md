The key point of this puzzle is everything on blockchain is public.
Although data state variable is private, but it still visible to everybody.

```shell
    anvil
```

Running local anvil, and deploy `Pricacy` contract on it.

```shell
    forge script ./script/Pricacy.s.sol
        --rpc-url http://127.0.0.1:8545
        --private-key=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --sender=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
        --broadcast
        -vvvv

    Transaction: 0x73b13fac177d47b31f25bc8bc3d0b1a66d4522119053aa15db2c9d97b50c8ccb
    Contract created: 0x5fbdb2315678afecb367f032d93f642f64180aa3
    Gas used: 253173

    Block Number: 1
    Block Hash: 0x243a268e7a6f35f2d3ce544dda6047ad13395e95abbd77b4bf10599a89b8b98a
    Block Time: "Sat, 09 Sep 2023 01:46:29 +0000"
```

We can see the contract address is `0x5fbdb2315678afecb367f032d93f642f64180aa3`

Then we can use `cast storage` command to check the state variable in this contract
Note that, the `data[2]` is on slot 5

```shell
    cast storage --rpc-url http://127.0.0.1:8545 0x5fbdb2315678afecb367f032d93f642f64180aa3 5

    0x7c4132911140941f6873d6de6aaf49338f9d8e96290e457f8e061096f66518fe
```

We get this 32 bytes back, an we can use this to unlock the `Privacy` contract.
