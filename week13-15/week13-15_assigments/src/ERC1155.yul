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
            case 0xe985e9c5 /* "isApprovedForAll(address,address)" */ {
                returnUint(isApprovedForAll(decodeAsAddress(0), decodeAsAddress(1)))
            }
            case 0x731133e9 /* "mint(address,uint256,uint256,bytes)" */ {
                mint(decodeAsAddress(0), decodeAsUint(1), decodeAsUint(2), decodeAsDynamicTypePtr(3))
            }
            case 0xb48ab8b6 /* "batchMint(address,uint256[],uint256[],bytes)" */ {
                mintBatch(decodeAsAddress(0), decodeAsDynamicTypePtr(1), decodeAsDynamicTypePtr(2), decodeAsDynamicTypePtr(3))
            }
            case 0xf5298aca /* "burn(address,uint256,uint256)" */ {
                burn(decodeAsAddress(0), decodeAsUint(1), decodeAsUint(2))
            }
            case 0xf6eb127a /* "batchBurn(address,uint256[],uint256[])" */ {
                batchBurn(decodeAsAddress(0), decodeAsDynamicTypePtr(1), decodeAsDynamicTypePtr(2))
            }
            case 0x2eb2c2d6 /* "safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)" */ {}
            case 0xf242432a /* "safeTransferFrom(address,address,uint256,uint256,bytes)" */ {}
            case 0xa22cb465 /* "setApprovalForAll(address,bool)" */ {
                setApprovalForAll(decodeAsAddress(0), decodeAsUint(1))
            }
            case 0x01ffc9a7 /* "supportsInterface(bytes4)" */ {}
            case 0x0e89341c /* "uri(uint256)" */ {}
            default /* "fallback()" */ {}
            

            /* ---------- functionality ----------- */
            function memoryInitialization() {
                mstore(0x40, 0x80)
            }
            function mint(to, tokenId, amount, dataPtr) {
                // to != address(0)
                require(iszero(eq(to, 0)))

                sstore(tokenIdToAccountToBalancePos(tokenId, to), amount)

                if isContract(to) {
                    let success := doSafeTransferAcceptanceCheck(caller(), 0, to, tokenId, amount, dataPtr)
                    require(success)

                }

                emitTransferSingle(caller(), 0, to, tokenId, amount)
            }
            function mintBatch(to, idsPtr, amountsPtr, dataPtr) {
                // to != address(0)
                require(iszero(eq(to, 0)))
                let idsLen := getDynamicTypeLen(idsPtr)
                let amountsLen := getDynamicTypeLen(amountsPtr)
                require(eq(idsLen, amountsLen))

                let idItem := getDynamicTypeActualDataPtr(idsPtr)
                let amountItem := getDynamicTypeActualDataPtr(amountsPtr)

                for { let i := 0 } lt(i, idsLen) { i := add(i, 1) } {
                    let tokenId := calldataload(add(idItem, mul(i, 0x20)))
                    let amount := calldataload(add(amountItem, mul(i, 0x20)))

                    sstore(tokenIdToAccountToBalancePos(tokenId, to), amount)
                }

                if isContract(to) {
                    let success := doSafeBatchTransferAcceptanceCheck(caller(), 0, to, idsPtr, amountsPtr, dataPtr)
                    require(success)
                }

                emitTransferBatch(caller(), 0, to, idsPtr, amountsPtr)
            }
            function burn(from, tokenId, amount) {
                require(iszero(eq(from, 0)))

                let fromBalance := balanceOf(from, tokenId)
                require(gte(fromBalance, amount))

                sstore(tokenIdToAccountToBalancePos(tokenId, from), sub(fromBalance, amount))

                emitTransferSingle(caller(), from, 0, tokenId, amount)
                
            }
            function batchBurn(from, idsPtr, amountsPtr) {
                require(iszero(eq(from, 0)))

                let idsLen := getDynamicTypeLen(idsPtr)
                let amountsLen := getDynamicTypeLen(amountsPtr)
                require(eq(idsLen, amountsLen))

                let idItem := getDynamicTypeActualDataPtr(idsPtr)
                let amountItem := getDynamicTypeActualDataPtr(amountsPtr)

                for { let i := 0 } lt(i, idsLen) { i := add(i, 1) } {
                    let tokenId := calldataload(add(idItem, mul(i, 0x20)))
                    let amount := calldataload(add(amountItem, mul(i, 0x20)))

                    let fromBalance := balanceOf(from, tokenId)
                    require(gte(fromBalance, amount))

                    sstore(tokenIdToAccountToBalancePos(tokenId, from), sub(fromBalance, amount))
                }

                emitTransferBatch(caller(), from, 0, idsPtr, amountsPtr)
            }
            function setApprovalForAll(spender, approved) {
                let owner := caller()

                require(iszero(eq(owner, spender)))
                require(or(eq(approved, 0), eq(approved, 1)))

                sstore(ownerToSpenderToApproved(owner, spender), approved)

                emitApprovalForAll(caller(), spender, approved)
            }
            function isApprovedForAll(owner, spender) -> b {
                b := sload(ownerToSpenderToApproved(owner, spender))
            }
            function balanceOf(account, tokenId) -> v {
                v := sload(tokenIdToAccountToBalancePos(tokenId, account))
            }
            function emitTransferSingle(operator, from, to, tokenId, amount) {
                // "TransferSingle(address,address,address,uint256,uint256)" 
                // 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62
                let topic1 := 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62

                mstore(0x00, tokenId)
                mstore(0x20, amount)

                log4(0x00, 0x40, topic1, operator, from, to)
            }
            function emitTransferBatch(operator, from, to, idsPtr, amountsPtr) {
                // "TransferBatch(address,address,address,uint256[],uint256[])" 
                // 0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb
                let topic1 := 0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb

                let oldFmptr := getFmptr()

                // "uint256[],uint256[])"

                // calculate dynamic type offset
                // 1 slot = 32 bytes
                let slots := 2
                mstore(oldFmptr, mul(0x20, slots))

                // amounts offset
                let idsLen := getDynamicTypeLen(idsPtr)
                slots := add(add(idsLen, 1), slots)
                mstore(add(oldFmptr, 0x20), mul(0x20, slots))

                let amountsLen := getDynamicTypeLen(amountsPtr)
                // ids + amounts
                let totalDataLen := mul(add(add(idsLen, amountsLen), 2), 0x20)
                // actual data portion starts from the idsLen offset
                calldatacopy(add(oldFmptr, 0x40), idsPtr, totalDataLen)

                log4(oldFmptr, add(0x40, totalDataLen), topic1, operator, from, to)

                updateFmptr(add(0x40, totalDataLen))
            }
            function emitApprovalForAll(owner, spender, approved) {
                // "ApprovalForAll(address,address,bool)"
                // 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31
                let topic1 := 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31
                mstore(0x00, approved)

                log3(0x00, 0x20, topic1, owner, spender)
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
                let oldFmptr := getFmptr()

                // f23a6e61 -> "onERC1155Received(address,address,uint256,uint256,bytes)"
                mstore(oldFmptr, 0xf23a6e61)
                mstore(add(oldFmptr, 0x20), operator)
                mstore(add(oldFmptr, 0x40), from)
                mstore(add(oldFmptr, 0x60), tokenId)
                mstore(add(oldFmptr, 0x80), amount)

                // calculate dynamic type offset
                // 1 slot = 32 bytes
                let slots := 5
                mstore(add(oldFmptr, 0xa0), mul(0x20, slots))

                // only data
                let totalDataLen := sub(calldatasize(), 0x84)

                // actual data portion starts from the data offset
                calldatacopy(add(oldFmptr, 0xc0), dataPtr, totalDataLen)

                v := call(gas(), to, 0, add(oldFmptr, 0x1c), add(0xc4, totalDataLen), 0, 0)

                updateFmptr(add(0xc4, totalDataLen))
            }
            function doSafeBatchTransferAcceptanceCheck(operator, from, to, idsPtr, amountsPtr, dataPtr) -> v {
                let oldFmptr := getFmptr()

                // bc197c81 -> "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                mstore(oldFmptr, 0xbc197c81)
                mstore(add(oldFmptr, 0x20), operator)
                mstore(add(oldFmptr, 0x40), from)

                // calculate dynamic type offset
                // 1 slot = 32 bytes
                let slots := 5

                // ids offset
                mstore(add(oldFmptr, 0x60), mul(0x20, slots))

                // amounts offset
                let idsLen := getDynamicTypeLen(idsPtr)
                slots := add(add(idsLen, 1), slots)
                mstore(add(oldFmptr, 0x80), mul(0x20, slots))

                // data offset
                let amountsLen := getDynamicTypeLen(amountsPtr)
                slots := add(add(amountsLen, 1), slots)
                mstore(add(oldFmptr, 0xa0), mul(0x20, slots))

                // ids + amounts + data
                let totalDataLen := sub(calldatasize(), 0x84)
                // actual data portion starts from the idsLen offset
                calldatacopy(add(oldFmptr, 0xc0), idsPtr, totalDataLen )

                v := call(gas(), to, 0, add(oldFmptr, 0x1c), add(0xe4, totalDataLen), 0, 0)

                updateFmptr(add(0xe4, totalDataLen))
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
            function ownerToSpenderToApproved(owner, spender) -> p {
                p := hashTwoValues(spender, hashTwoValues(owner, operatorApprovalMapPos()))
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
            function getDynamicTypeLen(dyPtr) -> v {
                // note that after `decodeAsDynamicTypePtr`, dyPtr already point to the DataLen
                v := calldataload(dyPtr)
            }
            function getDynamicTypeActualDataPtr(dyPtr) -> v {
                // note that after `decodeAsDynamicTypePtr`, dyPtr already point to the DataLen
                // return the pointer point to where the data begin
                v := add(dyPtr, 0x20)
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