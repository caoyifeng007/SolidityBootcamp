Contract addresses are deterministically calculated.

reference

1. https://docs.soliditylang.org/en/latest/control-structures.html#salted-contract-creations-create2
2. https://www.evm.codes/#f0?fork=shanghai

```python
address = keccak256(rlp([sender_address,sender_nonce]))[12:]
```

0x01 is the nonce used for creating that contract.

```shell
// output 0xd6943bd0ca2769369d73012f81094520975c0378e7ad01
cast to-rlp '["0x3bD0CA2769369D73012f81094520975C0378e7aD","0x01"]'

// output 0x5c364740fa921296a0073f1e10638c1ba32dd13846d4820f56b686a5c2b0b144
cast keccak 0xd694d7acd2a9fd159e69bb102a1ca21c9a3e3a5f771b01
```

rightmost 20 bytes consist of the final address:
0x10638c1ba32dd13846d4820f56b686a5c2b0b144

```shell
// 0x00f55d9d000000000000000000000000f62f586830864ecf821bdeba2e96dc6c154beb87
cast calldata "destroy(address)" 0xf62F586830864EcF821BDeBA2E96dC6c154BEb87
```

Using Metamask make a raw transaction call with calldata above to address we calculated.
Then we can finish the puzzle.
