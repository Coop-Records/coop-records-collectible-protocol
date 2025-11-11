// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {ProtocolRewards} from "@zoralabs/protocol-rewards/src/ProtocolRewards.sol";

/// @notice Forge script that deploys the ProtocolRewards contract.
contract DeployProtocolRewards is Script {
    /// @notice Deploys ProtocolRewards via broadcast and logs the address.
    function run() external returns (address deployedAddress) {
        vm.startBroadcast();

        ProtocolRewards protocolRewards = new ProtocolRewards{value: 0}();
        deployedAddress = address(protocolRewards);

        vm.stopBroadcast();

        console2.log("ProtocolRewards deployed at:", deployedAddress);
    }
}

