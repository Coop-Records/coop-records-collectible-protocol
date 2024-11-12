// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {SecondarySwap} from "../src/helper/SecondarySwap.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {ISwapRouter} from "../src/interfaces/uniswap/ISwapRouter.sol";
import {IZoraTimedSaleStrategy} from "../src/interfaces/IZoraTimedSaleStrategy.sol";
import {DeployerBase} from "./DeployerBase.sol";

contract DeploySwapHelperSimple is DeployerBase {

    function run() public {
        // Read existing deployment config
        DeploymentConfig memory config = readDeployment();

        vm.startBroadcast();

        // Deploy SecondarySwap contract
        SecondarySwap swapHelper = new SecondarySwap();

        // Get required addresses
        IWETH weth = IWETH(getWeth());
        ISwapRouter swapRouter = ISwapRouter(getUniswapSwapRouter());
        IZoraTimedSaleStrategy zoraStrategy = IZoraTimedSaleStrategy(0x633B528311ED1DeEcD622863717D1a29b1B02BCB);

        // Set Uniswap pool fee (1% = 10_000)
        uint24 uniswapPoolFee = 10_000;

        // Initialize the contract
        swapHelper.initialize(
            weth,
            swapRouter,
            uniswapPoolFee,
            zoraStrategy
        );

        // Store deployed address in config
        config.swapHelper = address(swapHelper);

        console2.log("SwapHelper deployed to:", vm.toString(block.chainid), config.swapHelper);

        vm.stopBroadcast();

        // Save updated deployment config
        saveDeployment(config);
    }
}
