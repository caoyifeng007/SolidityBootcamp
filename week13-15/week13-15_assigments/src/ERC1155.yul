// SPDX-License-Identifier: UNLICENSED

object "ERC1155Token" {
    code {
        // Store the creator in slot zero.
        sstore(0, caller())

        // Deploy the contract
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }
    object "runtime" {
        code {
            memoryInitialization()
            // Dispatcher
            switch selector()
            case 0x00fdd58e /* "balanceOf(address,uint256)" */ {
                returnUint(balanceOf(decodeAsAddress(0), decodeAsUint(1)))
            }
            case 0x4e1273f4 /* "balanceOfBatch(address[],uint256[])" */ {
                // returnUint(balanceOfBatch())
            }
            case 0xe985e9c5 /* "isApprovedForAll(address,address)" */ {}
            case 0x731133e9 /* "mint(address,uint256,uint256,bytes)" */ {
                mint(decodeAsAddress(0), decodeAsUint(1), decodeAsUint(2), decodeAsDynamicTypePtr(3))
            }
            case 0x2eb2c2d6 /* "safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)" */ {}
            case 0xf242432a /* "safeTransferFrom(address,address,uint256,uint256,bytes)" */ {}
            case 0xa22cb465 /* "setApprovalForAll(address,bool)" */ {}
            case 0x01ffc9a7 /* "supportsInterface(bytes4)" */ {}
            case 0x0e89341c /* "uri(uint256)" */ {}
            default /* "fallback()" */ {}
            

            /* ---------- functionality ----------- */
            function memoryInitialization() {
                mstore(0x40, 0x80)
            }
            function mint(to, tokenId, amount, dataPtr) {
                // account != address(0)
                require(iszero(eq(to, 0)))

                sstore(tokenIdToAccountToBalancePos(tokenId, to), amount)

                if isContract(to) {

                    let success := doSafeTransferAcceptanceCheck(caller(), 0, to, tokenId, amount, dataPtr)

                    require(success)
                    
                    updateFmptr(0xe4)

                }

                returnTrue()
            }
            function balanceOf(account, tokenId) -> v {
                v := sload(tokenIdToAccountToBalancePos(tokenId, account))
            }
            /* ---------- calldata functionality ----------- */
            function selector() -> s {
                s := calldataload(0x00)
                s := shr(0xe0, s)
            }
            function decodeAsAddress(offset) -> v {
                v := decodeAsUint(offset)
                if iszero(iszero(and(v, not(0xffffffffffffffffffffffffffffffffffffffff)))) {
                    revert(0, 0)
                }
            }
            function decodeAsUint(offset) -> v {
                let pos := add(4, mul(offset, 0x20))
                if lt(calldatasize(), add(pos, 0x20)) {
                    revert(0, 0)
                }
                v := calldataload(pos)
            }
            function decodeAsDynamicTypePtr(offset) -> v {
                // return the pointer point to where the dataLen begin
                v := add(decodeAsUint(offset), 0x04)
            }
            function doSafeTransferAcceptanceCheck(operator, from, to, tokenId, amount, dataPtr) -> v {
                // f23a6e61 -> "onERC1155Received(address,address,uint256,uint256,bytes)"
                let oldFmptr := getFmptr()
                let dataLen := calldataload(dataPtr)

                mstore(oldFmptr, 0xf23a6e61)
                mstore(add(oldFmptr, 0x20), operator)
                mstore(add(oldFmptr, 0x40), from)
                mstore(add(oldFmptr, 0x60), tokenId)
                // mstore(add(oldFmptr, 0x60), dataLen)
                mstore(add(oldFmptr, 0x80), amount)

                mstore(add(oldFmptr, 0xa0), 0xa0)
                mstore(add(oldFmptr, 0xc0), dataLen)
                // skip the dataLen, copy the actual data
                calldatacopy(add(oldFmptr, 0xe0), add(dataPtr, 0x20), dataLen)

                // mstore(add(oldFmptr, 0xc0), 11)
                // mstore(add(oldFmptr, 0xe0), 0x74657374696e6720313233000000000000000000000000000000000000000000)

                // there is an 32-bytes long memory containing dataLen in this calldatacopy
                // don't forget to add this 0x20 in the call
                v := call(gas(), to, 0, add(oldFmptr, 0x1c), add(0xe4, dataLen), 0, 0)
                // v := call(gas(), to, 0, add(oldFmptr, 0x1c), 0xe4 , 0, 0)
            }
            function returnUint(v) {
                mstore(0, v)
                return(0, 0x20)
            }
            function returnTrue() {
                returnUint(1)
            }

            /* -------- storage layout ---------- */
            function balanceMapPos() -> p { p := 0 }
            function operatorApprovalMapPos() -> p { p := 1 }
            function tokenIdToAccountToBalancePos(tokenId, account) -> p {
                p := hashTwoValues(account, hashTwoValues(tokenId, balanceMapPos()))
            }
           

            /* ---------- utility functions ---------- */
            function hashTwoValues(a, b) -> r {
                mstore(0x00, a)
                mstore(0x20, b)

                r := keccak256(0x00, 0x40)
            }
            function getFmptr() -> r {
                r := mload(0x40)
            }
            function updateFmptr(increase) {
                mstore(0x40, add(getFmptr(), increase))
            }
            function isContract(account) -> r {
                r := gt(extcodesize(account), 0)
            }
            function lte(a, b) -> r {
                r := iszero(gt(a, b))
            }
            function gte(a, b) -> r {
                r := iszero(lt(a, b))
            }
            function safeAdd(a, b) -> r {
                r := add(a, b)
                if or(lt(r, a), lt(r, b)) { revert(0, 0) }
            }
            // function calledByOwner() -> cbo {
            //     cbo := eq(owner(), caller())
            // }
            function revertIfZeroAddress(addr) {
                require(addr)
            }
            function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }
        }
    }
}