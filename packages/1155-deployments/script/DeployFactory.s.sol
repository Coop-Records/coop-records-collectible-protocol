// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {Zora1155Factory} from "@1155-contracts/src/proxies/Zora1155Factory.sol";
import {ZoraCreator1155FactoryImpl} from "@1155-contracts/src/factory/ZoraCreator1155FactoryImpl.sol";

contract DeployFactory is Script {
    function run() public {
        vm.startBroadcast();

        address factoryImpl = 0xB805ccd51d559E573a20596603052af3aD7F3087;

        // Initialize data for proxy
        bytes memory initData = abi.encodeWithSelector(
            ZoraCreator1155FactoryImpl.initialize.selector,
            0x58BE4B98fec63651287A2741665E7a200De43916  // initial owner address
        );

        // Deploy proxy
        Zora1155Factory proxy = new Zora1155Factory(
            factoryImpl,
            initData
        );

        console2.log("Factory proxy deployed to:", address(proxy));

        vm.stopBroadcast();
    }
} 