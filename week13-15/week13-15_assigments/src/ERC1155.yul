// SPDX-License-Identifier: UNLICENSED

object "ERC1155Token" {
    code {
        // store the uri in slot 2.
        let totalLen := codesize()
        let creationLen := datasize("ERC1155Token")
        let argLen := sub(totalLen, creationLen)

        // arg starts from the end of creation code
        codecopy(0x00, creationLen, argLen)

        let strLen := mload(0x20)

        // short string, strLen <= 31
        if lt(strLen, 32) {
            let str := mload(0x40)
            sstore(2, or(str, mul(strLen, 2)))
        }

        // long string, strLen >= 32
        if gt(strLen, 31) {
            sstore(2, add(mul(strLen, 2), 1))

            mstore(0x00, 0x02)
            let location := keccak256(0x00, 0x20)

            let iteration := div(strLen, 0x20)
            if mod(strLen, 0x20) {
                iteration := add(iteration, 1)
            }

            let increase := 0
            let item := 0
            for { let i := 0 } lt(i, iteration) { i := add(i, 1) } {
                item := mload(add(0x40, increase))
                sstore(add(location, i), item)

                increase := add(increase, 0x20)
            } 
        }

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
                balanceOfBatch(decodeAsDynamicTypePtr(0), decodeAsDynamicTypePtr(1))
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
            case 0x2eb2c2d6 /* "safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)" */ {
                safeBatchTransferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsDynamicTypePtr(2), decodeAsDynamicTypePtr(3), decodeAsDynamicTypePtr(4))
            }
            case 0xf242432a /* "safeTransferFrom(address,address,uint256,uint256,bytes)" */ {
                safeTransferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2), decodeAsUint(3),decodeAsDynamicTypePtr(4))
            }
            case 0xa22cb465 /* "setApprovalForAll(address,bool)" */ {
                setApprovalForAll(decodeAsAddress(0), decodeAsUint(1))
            }
            case 0x01ffc9a7 /* "supportsInterface(bytes4)" */ {
                returnUint(supportsInterface(decodeAsUint(0)))
            }
            case 0x0e89341c /* "uri(uint256)" */ {
                uri(decodeAsUint(0))
            }
            default /* "fallback()" */ {}
            

            /* ---------- functionality ----------- */
            function memoryInitialization() {
                mstore(0x40, 0x80)
            }
            function mint(to, tokenId, amount, dataPtr) {
                revertIfZeroAddress(to)

                let toBalance := balanceOf(tokenId, to)
                sstore(tokenIdToAccountToBalancePos(tokenId, to), safeAdd(toBalance, amount))

                if isContract(to) {
                    let success := doSafeTransferAcceptanceCheck(caller(), 0, to, tokenId, amount, dataPtr)
                    require(success)
                }

                emitTransferSingle(caller(), 0, to, tokenId, amount)
            }
            function mintBatch(to, idsPtr, amountsPtr, dataPtr) {
                revertIfZeroAddress(to)

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
                revertIfZeroAddress(from)

                let fromBalance := balanceOf(from, tokenId)
                require(gte(fromBalance, amount))

                sstore(tokenIdToAccountToBalancePos(tokenId, from), sub(fromBalance, amount))

                emitTransferSingle(caller(), from, 0, tokenId, amount)
                
            }
            function batchBurn(from, idsPtr, amountsPtr) {
                revertIfZeroAddress(from)

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
            function safeTransferFrom(from, to, tokenId, amount, dataPtr) {
                revertIfZeroAddress(to)

                let operator := caller()
                require(or(eq(from, operator), eq(isApprovedForAll(from, operator), 1)))

                let fromBalance := balanceOf(from, tokenId)
                require(gte(fromBalance, amount))

                sstore(tokenIdToAccountToBalancePos(tokenId, from), sub(fromBalance, amount))

                let toBalance := balanceOf(to, tokenId)
                sstore(tokenIdToAccountToBalancePos(tokenId, to), safeAdd(toBalance, amount))

                if isContract(to) {
                    let success := doSafeTransferAcceptanceCheck(operator, from, to, tokenId, amount, dataPtr)
                    require(success)
                }

                emitTransferSingle(operator, from, to, tokenId, amount)
            }
            function safeBatchTransferFrom(from, to, idsPtr, amountsPtr, dataPtr) {
                revertIfZeroAddress(to)

                let operator := caller()
                require(or(eq(from, operator), eq(isApprovedForAll(from, operator), 1)))

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

                    let toBalance := balanceOf(to, tokenId)
                    sstore(tokenIdToAccountToBalancePos(tokenId, to), safeAdd(toBalance, amount))

                }

                if isContract(to) {
                    let success := doSafeBatchTransferAcceptanceCheck(operator, from, to, idsPtr, amountsPtr, dataPtr)
                    require(success)
                }

                emitTransferBatch(operator, from, to, idsPtr, amountsPtr)
            }
            function balanceOf(account, tokenId) -> v {
                v := sload(tokenIdToAccountToBalancePos(tokenId, account))
            }
            function balanceOfBatch(tosPtr, idsPtr) {
                let tosLen := getDynamicTypeLen(tosPtr)
                let idsLen := getDynamicTypeLen(idsPtr)
                require(eq(tosLen, idsLen))

                let oldFmptr := getFmptr()
                mstore(oldFmptr, 0x20)
                mstore(add(oldFmptr, 0x20), tosLen)

                let toItem := getDynamicTypeActualDataPtr(tosPtr)
                let idItem := getDynamicTypeActualDataPtr(idsPtr)

                // there are two slots used
                let offset := 0x40
                for { let i := 0 } lt(i, tosLen) { i := add(i, 1) } {
                    let to := calldataload(add(toItem, mul(i, 0x20)))
                    let id := calldataload(add(idItem, mul(i, 0x20)))

                    let b := balanceOf(to, id)

                    mstore(add(oldFmptr, offset), b)
                    offset := add(offset, 0x20)
                }

                return(oldFmptr, add(oldFmptr, offset))
            }
            function supportsInterface(interfaceId) -> b {
                interfaceId := shr(0xe0, interfaceId)

                // IERC165 -> 0x01ffc9a7
                b := eq(interfaceId, 0x01ffc9a7)
                // IERC1155MetadataURI -> 0x0e89341c
                b := or(eq(interfaceId, 0x0e89341c), b)
                // IERC1155 -> 0xd9b67a26
                b := or(eq(interfaceId, 0xd9b67a26), b)
            }
            function uri(tokenId) {

                let uriStorageVal := sload(uriPos())
                let storedLen := and(uriStorageVal , 0xff)
                let strLen := 0

                // if strLen is 31, then 31 * 2 will be 0x3e
                // 2 * strLen < 0x3f, short string
                if lt(storedLen, 0x3f) {
                    strLen := div(storedLen, 2)
                    mstore(0x00, 0x20)
                    mstore(0x20, strLen)
                    mstore(0x40, uriStorageVal)

                    return(0x00, add(strLen, 0x40))
                }

                // if strLen is 32, then 32 * 2 + 1 will be 0x41
                // 2 * strLen + 1 > 0x40, long string
                if gt(storedLen, 0x40) {

                    strLen := div(sub(storedLen, 1), 2)

                    let iteration := div(strLen, 0x20)
                    if mod(strLen, 0x20) {
                        iteration := add(iteration, 1)
                    }

                    mstore(0x00, 0x02)
                    let location := keccak256(0x00, 0x20)

                    mstore(0x00, 0x20)
                    mstore(0x20, strLen)

                    let increase := 0
                    for { let i := 0 } lt(i, iteration) { i := add(i, 1) } {
                        let item := sload(add(location, i))

                        mstore(add(0x40, increase), item)
                        increase := add(increase, 0x20)
                    } 

                    return(0x00, add(mul(iteration, 0x20), 0x40))
                }
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

                let success := call(gas(), to, 0, add(oldFmptr, 0x1c), add(0xc4, totalDataLen), 0, 0x20)
                require(success)

                require(eq(mload(0x00), 0xf23a6e61))

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

                let success := call(gas(), to, 0, add(oldFmptr, 0x1c), add(0xe4, totalDataLen), 0, 0x20)
                require(success)

                require(eq(mload(0x00), 0xbc197c81))

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
            function uriPos() -> p { p := 2 }
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
            function revertIfZeroAddress(addr) {
                require(addr)
            }
            function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }
        }
    }
}