// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {Zora1155Factory} from "@1155-contracts/src/proxies/Zora1155Factory.sol";
import {CoopCreator1155FactoryImpl} from "@1155-contracts/src/factory/CoopCreator1155FactoryImpl.sol";
import {ZoraDeployerBase} from "../src/ZoraDeployerBase.sol";
import {Deployment, ChainConfig} from "../src/DeploymentConfig.sol";

contract DeployFactory is ZoraDeployerBase {
    function run() public returns (string memory) {
        Deployment memory deployment = getDeployment();
        ChainConfig memory chainConfig = getChainConfig();

        vm.startBroadcast();

        // Initialize data for proxy
        bytes memory initData = abi.encodeWithSelector(
            CoopCreator1155FactoryImpl.initialize.selector,
            chainConfig.factoryOwner  // initial owner address from chain config
        );

        // Deploy proxy
        Zora1155Factory proxy = new Zora1155Factory(
            deployment.factoryImpl, // factory implementation from deployment JSON
            initData
        );

        deployment.factoryProxy = address(proxy);
        console2.log("Factory proxy deployed to:", address(proxy));

        vm.stopBroadcast();

        return getDeploymentJSON(deployment);
    }
} 