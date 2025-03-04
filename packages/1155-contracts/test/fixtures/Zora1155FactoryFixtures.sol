// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {CoopCreator1155Impl} from "../../src/nft/CoopCreator1155Impl.sol";
import {ZoraCreatorFixedPriceSaleStrategy} from "../../src/minters/fixed-price/ZoraCreatorFixedPriceSaleStrategy.sol";
import {ICoopCreator1155Errors} from "../../src/interfaces/ICoopCreator1155Errors.sol";
import {ICoopCreator1155} from "../../src/interfaces/ICoopCreator1155.sol";
import {IMinter1155} from "../../src/interfaces/IMinter1155.sol";
import {Coop1155Factory} from "../../src/proxies/Coop1155Factory.sol";
import {CoopCreator1155FactoryImpl} from "../../src/factory/CoopCreator1155FactoryImpl.sol";
import {ProtocolRewards} from "@zoralabs/protocol-rewards/src/ProtocolRewards.sol";
import {ProxyShim} from "../../src/utils/ProxyShim.sol";
import {IUpgradeGate} from "../../src/interfaces/IUpgradeGate.sol";
import {UpgradeGate} from "../../src/upgrades/UpgradeGate.sol";

library Zora1155FactoryFixtures {
    function setupZora1155Impl(
        address zora,
        IUpgradeGate upgradeGate
    ) internal returns (ProtocolRewards rewards, CoopCreator1155Impl zora1155Impl, address timedSaleStrategy) {
        // Ignore in this case
        timedSaleStrategy = address(0x0);
        rewards = new ProtocolRewards();
        zora1155Impl = new CoopCreator1155Impl(zora, address(upgradeGate), address(rewards), timedSaleStrategy);
    }

    function upgradeFactoryProxyToUse1155(
        Coop1155Factory factoryProxy,
        ICoopCreator1155 zoraCreator1155Impl,
        IMinter1155 fixedPriceMinter,
        address admin
    ) internal returns (CoopCreator1155FactoryImpl factoryImpl) {
        factoryImpl = new CoopCreator1155FactoryImpl(zoraCreator1155Impl, IMinter1155(address(1)), fixedPriceMinter, IMinter1155(address(3)));

        CoopCreator1155FactoryImpl factoryAtProxy = CoopCreator1155FactoryImpl(address(factoryProxy));

        factoryAtProxy.upgradeTo(address(factoryImpl));
        factoryAtProxy.initialize(admin);
    }

    function setupFactoryProxy(address deployer) internal returns (Coop1155Factory factoryProxy) {
        address factoryShimAddress = address(new ProxyShim(deployer));
        factoryProxy = new Coop1155Factory(factoryShimAddress, "");
    }

    function setupNew1155AndFactory(
        address zora,
        IUpgradeGate upgradeGate,
        IMinter1155 fixedPriceMinter
    ) internal returns (ProtocolRewards rewards, CoopCreator1155Impl zoraCreator1155Impl, CoopCreator1155FactoryImpl factoryImpl) {
        (rewards, zoraCreator1155Impl, ) = setupZora1155Impl(zora, upgradeGate);
        factoryImpl = new CoopCreator1155FactoryImpl(zoraCreator1155Impl, IMinter1155(address(1)), fixedPriceMinter, IMinter1155(address(3)));
    }

    function setup1155AndFactoryProxy(
        address zora,
        address deployer
    )
        internal
        returns (
            ProtocolRewards rewards,
            CoopCreator1155Impl zoraCreator1155Impl,
            IMinter1155 fixedPriceMinter,
            Coop1155Factory factoryProxy,
            IUpgradeGate upgradeGate
        )
    {
        factoryProxy = setupFactoryProxy(deployer);
        fixedPriceMinter = new ZoraCreatorFixedPriceSaleStrategy();
        upgradeGate = new UpgradeGate();
        (rewards, zoraCreator1155Impl, ) = setupZora1155Impl(zora, upgradeGate);
        upgradeFactoryProxyToUse1155(factoryProxy, zoraCreator1155Impl, fixedPriceMinter, deployer);
    }
}
