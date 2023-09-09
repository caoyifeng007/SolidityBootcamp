// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

contract YulDeployer is Test {
    ///@notice Compiles a Yul contract and returns the address that the contract was deployed to
    ///@notice If deployment fails, an error will be thrown
    ///@param fileName - Relative file path in terms of project root directory
    ///@return deployedAddress - The address that the contract was deployed to
    function deployContract(string memory fileName) public returns (address) {
        string memory subCommand = string.concat(
            "solc --yul ",
            fileName,
            " --bin | tail -1"
        );

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = subCommand;

        bytes memory bytecode = vm.ffi(inputs);

        ///@notice deploy the bytecode with the create instruction
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        ///@notice check that the deployment was successful
        require(
            deployedAddress != address(0),
            "YulDeployer could not deploy contract"
        );

        ///@notice return the address that the contract was deployed to
        return deployedAddress;
    }

    function testFilePath() external {
        address c = deployContract("src/MagicNumber/Attacker.yul");

        // assertEq(a, b);
    }
}
