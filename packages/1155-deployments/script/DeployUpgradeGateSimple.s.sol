// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "forge-std/StdJson.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {UpgradeGate} from "@zoralabs/zora-1155-contracts/src/upgrades/UpgradeGate.sol";

/// @notice Deploys an UpgradeGate and logs the deployed address.
contract DeployUpgradeGateSimple is Script {
    using stdJson for string;

    /// @notice Deploys UpgradeGate and initializes with the FACTORY_OWNER from chain config.
    function run() external returns (address deployedAddress) {
        address owner = _getFactoryOwner();

        vm.startBroadcast();
        UpgradeGate upgradeGate = new UpgradeGate();
        upgradeGate.initialize(owner);
        deployedAddress = address(upgradeGate);
        vm.stopBroadcast();

        console2.log("UpgradeGate deployed at:", deployedAddress);
        console2.log("UpgradeGate owner:", owner);
    }

    function _getFactoryOwner() private view returns (address) {
        string memory json = vm.readFile(string.concat("chainConfigs/", Strings.toString(block.chainid), ".json"));
        return json.readAddress(".FACTORY_OWNER");
    }
}

