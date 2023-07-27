// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ERC20_Sanction.sol";

contract SanctionTokenScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // solhint-disable-next-line
        SanctionToken token = new SanctionToken();

        vm.stopBroadcast();
    }
}
