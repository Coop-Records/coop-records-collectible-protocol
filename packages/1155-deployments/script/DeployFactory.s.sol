// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {Zora1155Factory} from "@1155-contracts/src/proxies/Zora1155Factory.sol";
import {ZoraCreator1155FactoryImpl} from "@1155-contracts/src/factory/ZoraCreator1155FactoryImpl.sol";

contract DeployFactory is Script {
    function run() public {
        vm.startBroadcast();

        // Initialize data for proxy
        bytes memory initData = abi.encodeWithSelector(
            ZoraCreator1155FactoryImpl.initialize.selector,
            0x749B7b7A6944d72266Be9500FC8C221B6A7554Ce  // initial owner address
        );

        // Deploy proxy
        Zora1155Factory proxy = new Zora1155Factory(
            0x7Db1785CAB53907208398c7943272EBD13DC39ba,
            initData
        );

        console2.log("Factory proxy deployed to:", address(proxy));

        vm.stopBroadcast();
    }
} 