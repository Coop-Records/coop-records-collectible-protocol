// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {ProtocolRewards} from "@zoralabs/protocol-rewards/src/ProtocolRewards.sol";
import {CoopCreator1155Impl} from "../../../src/nft/CoopCreator1155Impl.sol";
import {Coop1155} from "../../../src/proxies/Coop1155.sol";
import {IMinter1155} from "../../../src/interfaces/IMinter1155.sol";
import {ICreatorRoyaltiesControl} from "../../../src/interfaces/ICreatorRoyaltiesControl.sol";
import {ILimitedMintPerAddressErrors} from "../../../src/interfaces/ILimitedMintPerAddress.sol";
import {ERC20PresetMinterPauser} from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import {ERC20Minter} from "../../../src/minters/erc20/ERC20Minter.sol";
import {IERC20Minter} from "../../../src/interfaces/IERC20Minter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ICoopCreator1155Errors} from "../../../src/interfaces/ICoopCreator1155Errors.sol";

contract ERC20MinterTest is Test {
    CoopCreator1155Impl internal target;
    ERC20PresetMinterPauser currency;
    address payable internal admin = payable(address(0x999));
    address internal zora;
    address internal tokenRecipient;
    address internal fundsRecipient;
    address internal createReferral;
    address internal mintReferral;
    address internal owner;
    ERC20Minter internal minter;
    IERC20Minter.ERC20MinterConfig internal minterConfig;

    uint256 internal constant TOTAL_REWARD_PCT = 25;
    uint256 immutable BPS_TO_PERCENT = 100;
    uint256 internal constant CREATE_REFERRAL_PAID_MINT_REWARD_PCT = 0;
    uint256 internal constant MINT_REFERRAL_PAID_MINT_REWARD_PCT = 50_000000;
    uint256 internal constant ZORA_PAID_MINT_REWARD_PCT = 50_000000;
    uint256 internal constant FIRST_MINTER_REWARD_PCT = 0;
    uint256 immutable BPS_TO_PERCENT_8_DECIMAL_PERCISION = 100_000_000;

    event ERC20RewardsDeposit(
        address indexed createReferral,
        address indexed mintReferral,
        address indexed firstMinter,
        address zora,
        address collection,
        address currency,
        uint256 tokenId,
        uint256 createReferralReward,
        uint256 mintReferralReward,
        uint256 firstMinterReward,
        uint256 zoraReward
    );

    event ERC20MinterConfigSet(IERC20Minter.ERC20MinterConfig config);

    event OwnerSet(address indexed prevOwner, address indexed owner);

    event MintComment(address indexed sender, address indexed tokenContract, uint256 indexed tokenId, uint256 quantity, string comment);

    function setUp() external {
        zora = makeAddr("zora");
        tokenRecipient = makeAddr("tokenRecipient");
        fundsRecipient = makeAddr("fundsRecipient");
        createReferral = makeAddr("createReferral");
        mintReferral = makeAddr("mintReferral");
        owner = makeAddr("owner");

        bytes[] memory emptyData = new bytes[](0);
        ProtocolRewards protocolRewards = new ProtocolRewards();
        CoopCreator1155Impl targetImpl = new CoopCreator1155Impl(zora, address(0x1234), address(protocolRewards), address(0));
        Coop1155 proxy = new Coop1155(address(targetImpl));
        target = CoopCreator1155Impl(payable(address(proxy)));
        target.initialize("test", "test", ICreatorRoyaltiesControl.RoyaltyConfiguration(0, 0, address(0)), admin, emptyData);
        minter = new ERC20Minter();
        minter.initialize(zora, owner, TOTAL_REWARD_PCT);
        vm.prank(admin);
        currency = new ERC20PresetMinterPauser("Test currency", "TEST");
        minterConfig = minter.getERC20MinterConfig();
    }

    function setUpTargetSale(
        uint256 price,
        address tokenFundsRecipient,
        address tokenCurrency,
        uint256 quantity,
        ERC20Minter minterContract
    ) internal returns (uint256) {
        vm.startPrank(admin);
        uint256 newTokenId = target.setupNewTokenWithCreateReferral("https://zora.co/testing/token.json", quantity, createReferral);
        target.addPermission(newTokenId, address(minterContract), target.PERMISSION_BIT_MINTER());
        target.callSale(
            newTokenId,
            minterContract,
            abi.encodeWithSelector(
                ERC20Minter.setSale.selector,
                newTokenId,
                IERC20Minter.SalesConfig({
                    pricePerToken: price,
                    saleStart: 0,
                    saleEnd: type(uint64).max,
                    maxTokensPerAddress: 0,
                    fundsRecipient: tokenFundsRecipient,
                    currency: tokenCurrency
                })
            )
        );
        vm.stopPrank();

        return newTokenId;
    }

    function test_ERC20MinterInitializeEventIsEmitted() external {
        vm.expectEmit(true, true, true, true);
        IERC20Minter.ERC20MinterConfig memory newConfig = IERC20Minter.ERC20MinterConfig({
            zoraRewardRecipientAddress: zora,
            rewardRecipientPercentage: TOTAL_REWARD_PCT
        });
        emit ERC20MinterConfigSet(newConfig);

        minter = new ERC20Minter();
        minter.initialize(zora, owner, TOTAL_REWARD_PCT);
    }

    function test_ERC20MinterZoraAddrCannotInitializeWithAddressZero() external {
        minter = new ERC20Minter();

        vm.expectRevert(abi.encodeWithSignature("AddressZero()"));
        minter.initialize(address(0), owner, TOTAL_REWARD_PCT);
    }

    function test_ERC20MinterOwnerAddrCannotInitializeWithAddressZero() external {
        minter = new ERC20Minter();

        vm.expectRevert(abi.encodeWithSignature("OWNER_CANNOT_BE_ZERO_ADDRESS()"));
        minter.initialize(zora, address(0), TOTAL_REWARD_PCT);
    }

    function test_ERC20MinterRewardPercentageCannotBeGreaterThan100() external {
        minter = new ERC20Minter();

        vm.expectRevert(abi.encodeWithSignature("InvalidValue()"));
        minter.initialize(zora, owner, 101);
    }

    function test_ERC20MinterContractName() external {
        assertEq(minter.contractName(), "ERC20 Minter");
    }

    function test_ERC20MinterContractVersion() external {
        assertEq(minter.contractVersion(), "2.0.0");
    }

    function test_ERC20MinterAlreadyInitalized() external {
        minter = new ERC20Minter();
        minter.initialize(zora, owner, TOTAL_REWARD_PCT);

        vm.expectRevert(abi.encodeWithSignature("INITIALIZABLE_CONTRACT_ALREADY_INITIALIZED()"));
        minter.initialize(zora, owner, TOTAL_REWARD_PCT);
    }

    function test_ERC20MinterSaleConfigPriceTooLow() external {
        vm.startPrank(admin);
        uint256 newTokenId = target.setupNewToken("https://zora.co/testing/token.json", 10);
        target.addPermission(newTokenId, address(minter), target.PERMISSION_BIT_MINTER());

        bytes memory minterError = abi.encodeWithSignature("PricePerTokenTooLow()");
        vm.expectRevert(abi.encodeWithSignature("CallFailed(bytes)", minterError));
        target.callSale(
            newTokenId,
            minter,
            abi.encodeWithSelector(
                ERC20Minter.setSale.selector,
                newTokenId,
                IERC20Minter.SalesConfig({
                    pricePerToken: 1,
                    saleStart: 0,
                    saleEnd: type(uint64).max,
                    maxTokensPerAddress: 0,
                    fundsRecipient: address(0x123),
                    currency: address(currency)
                })
            )
        );
        vm.stopPrank();
    }

    function test_ERC20MinterRevertIfFundsRecipientAddressZero() external {
        vm.startPrank(admin);
        uint256 newTokenId = target.setupNewTokenWithCreateReferral("https://zora.co/testing/token.json", 1, createReferral);
        target.addPermission(newTokenId, address(minter), target.PERMISSION_BIT_MINTER());

        bytes memory minterError = abi.encodeWithSignature("AddressZero()");
        vm.expectRevert(abi.encodeWithSignature("CallFailed(bytes)", minterError));
        target.callSale(
            newTokenId,
            minter,
            abi.encodeWithSelector(
                ERC20Minter.setSale.selector,
                newTokenId,
                IERC20Minter.SalesConfig({
                    pricePerToken: 10_000,
                    saleStart: 0,
                    saleEnd: type(uint64).max,
                    maxTokensPerAddress: 0,
                    fundsRecipient: address(0),
                    currency: address(currency)
                })
            )
        );
        vm.stopPrank();
    }

    function test_ERC20MinterRevertIfCurrencyZero() external {
        vm.startPrank(admin);
        uint256 newTokenId = target.setupNewTokenWithCreateReferral("https://zora.co/testing/token.json", 1, createReferral);
        target.addPermission(newTokenId, address(minter), target.PERMISSION_BIT_MINTER());

        bytes memory minterError = abi.encodeWithSignature("AddressZero()");
        vm.expectRevert(abi.encodeWithSignature("CallFailed(bytes)", minterError));
        target.callSale(
            newTokenId,
            minter,
            abi.encodeWithSelector(
                ERC20Minter.setSale.selector,
                newTokenId,
                IERC20Minter.SalesConfig({
                    pricePerToken: 10_000,
                    saleStart: 0,
                    saleEnd: type(uint64).max,
                    maxTokensPerAddress: 0,
                    fundsRecipient: fundsRecipient,
                    currency: address(0)
                })
            )
        );
        vm.stopPrank();
    }

    function test_ERC20MinterRevertIfCurrencyDoesNotMatchSalesConfigCurrency() external {
        setUpTargetSale(10_000, fundsRecipient, address(currency), 1, minter);

        vm.expectRevert(abi.encodeWithSignature("InvalidCurrency()"));
        minter.mint(tokenRecipient, 1, address(target), 1, 1, makeAddr("0x123"), address(0), "");
    }

    function test_ERC20MinterRequestMintInvalid() external {
        vm.expectRevert(abi.encodeWithSignature("RequestMintInvalidUseMint()"));
        minter.requestMint(address(0), 1, 1, 1, "");
    }

    function test_ERC20MinterComputePaidMintRewards() external {
        uint256 totalValue = 500000000000000000; // 0.5 when converted from wei
        ERC20Minter.RewardsSettings memory rewardsSettings = minter.computePaidMintRewards(totalValue);

        assertEq(rewardsSettings.createReferralReward, 0);
        assertEq(rewardsSettings.mintReferralReward, 250000000000000000); // 50% of totalValue
        assertEq(rewardsSettings.firstMinterReward, 0);
        assertEq(rewardsSettings.zoraReward, 250000000000000000); // 50% of totalValue
        assertEq(
            rewardsSettings.createReferralReward + rewardsSettings.mintReferralReward + rewardsSettings.zoraReward + rewardsSettings.firstMinterReward,
            totalValue
        );
    }

    function test_ERC20MinterSaleFlow() external {
        uint96 pricePerToken = 10_000;
        uint256 quantity = 2;
        uint256 newTokenId = setUpTargetSale(pricePerToken, fundsRecipient, address(currency), quantity, minter);

        vm.deal(tokenRecipient, 1 ether);
        vm.prank(admin);
        uint256 totalValue = pricePerToken * quantity;
        currency.mint(address(tokenRecipient), totalValue);

        vm.prank(tokenRecipient);
        currency.approve(address(minter), totalValue);

        vm.startPrank(tokenRecipient);
        minter.mint(
            tokenRecipient,
            quantity,
            address(target),
            newTokenId,
            pricePerToken * quantity,
            address(currency),
            mintReferral,
            ""
        );
        vm.stopPrank();

        assertEq(target.balanceOf(tokenRecipient, newTokenId), quantity);
        assertEq(currency.balanceOf(fundsRecipient), 15000); // 75% of 20000
        assertEq(currency.balanceOf(address(zora)), 2500); // 12.5% of 20000 (50% of 25% totalReward)
        assertEq(currency.balanceOf(mintReferral), 2500); // 12.5% of 20000 (50% of 25% totalReward)
        assertEq(currency.balanceOf(admin), 0); // No first minter reward
        assertEq(currency.balanceOf(createReferral), 0); // No create referral reward
        assertEq(
            currency.balanceOf(address(zora)) +
                currency.balanceOf(fundsRecipient) +
                currency.balanceOf(mintReferral) +
                currency.balanceOf(admin) +
                currency.balanceOf(createReferral),
            totalValue
        );
    }

    function test_ERC20MinterSaleWithRewardsAddresses() external {
        uint96 pricePerToken = 100000000000000000; // 0.1 when converted from wei
        uint256 quantity = 5;
        uint256 newTokenId = setUpTargetSale(pricePerToken, fundsRecipient, address(currency), quantity, minter);

        vm.prank(admin);
        uint256 totalValue = pricePerToken * quantity;
        currency.mint(address(tokenRecipient), totalValue);

        vm.prank(tokenRecipient);
        currency.approve(address(minter), totalValue);

        vm.startPrank(tokenRecipient);
        minter.mint(
            tokenRecipient,
            quantity,
            address(target),
            newTokenId,
            pricePerToken * quantity,
            address(currency),
            mintReferral,
            ""
        );
        vm.stopPrank();

        assertEq(target.balanceOf(tokenRecipient, newTokenId), quantity);
        assertEq(currency.balanceOf(fundsRecipient), 375000000000000000); // 75% of 0.5e18
        assertEq(currency.balanceOf(address(zora)), 62500000000000000); // 12.5% of 0.5e18
        assertEq(currency.balanceOf(createReferral), 0); // No create referral reward
        assertEq(currency.balanceOf(mintReferral), 62500000000000000); // 12.5% of 0.5e18
        assertEq(
            currency.balanceOf(address(zora)) +
                currency.balanceOf(fundsRecipient) +
                currency.balanceOf(createReferral) +
                currency.balanceOf(mintReferral) +
                currency.balanceOf(admin),
            totalValue
        );
    }

    function test_ERC20MinterSaleFuzz(uint96 pricePerToken, uint256 quantity, uint8 rewardPct) external {
        vm.assume(quantity > 0 && quantity < 1_000_000_000);
        vm.assume(pricePerToken > 10_000 && pricePerToken < type(uint96).max);
        vm.assume(rewardPct > 0 && rewardPct < 100);

        ERC20Minter newMinter = new ERC20Minter();
        newMinter.initialize(address(zora), owner, rewardPct);

        uint256 tokenId = setUpTargetSale(pricePerToken, fundsRecipient, address(currency), quantity, newMinter);

        vm.prank(admin);
        uint256 totalValue = pricePerToken * quantity;
        currency.mint(address(tokenRecipient), totalValue);

        vm.prank(tokenRecipient);
        currency.approve(address(newMinter), totalValue);

        uint256 reward = (totalValue * rewardPct) / BPS_TO_PERCENT;
        uint256 createReferralReward = (reward * CREATE_REFERRAL_PAID_MINT_REWARD_PCT) / BPS_TO_PERCENT_8_DECIMAL_PERCISION;
        uint256 mintReferralReward = (reward * MINT_REFERRAL_PAID_MINT_REWARD_PCT) / BPS_TO_PERCENT_8_DECIMAL_PERCISION;
        uint256 firstMinterReward = (reward * FIRST_MINTER_REWARD_PCT) / BPS_TO_PERCENT_8_DECIMAL_PERCISION;
        uint256 zoraReward = reward - (createReferralReward + mintReferralReward + firstMinterReward);

        vm.startPrank(tokenRecipient);
        vm.expectEmit(true, true, true, true);
        emit ERC20RewardsDeposit(
            createReferral,
            mintReferral,
            address(admin),
            zora,
            address(target),
            address(currency),
            tokenId,
            createReferralReward,
            mintReferralReward,
            firstMinterReward,
            zoraReward
        );

        uint256 amount = pricePerToken * quantity;
        newMinter.mint(tokenRecipient, quantity, address(target), tokenId, amount, address(currency), mintReferral, "");
        vm.stopPrank();

        assertEq(target.balanceOf(tokenRecipient, tokenId), quantity);
        assertEq(currency.balanceOf(address(zora)), zoraReward);
        assertEq(currency.balanceOf(createReferral), createReferralReward);
        assertEq(currency.balanceOf(mintReferral), mintReferralReward);
        assertEq(currency.balanceOf(admin), firstMinterReward);
        assertEq(currency.balanceOf(address(zora)) + currency.balanceOf(mintReferral) + currency.balanceOf(admin) + currency.balanceOf(createReferral), reward);
        assertEq(
            currency.balanceOf(address(zora)) +
                currency.balanceOf(fundsRecipient) +
                currency.balanceOf(createReferral) +
                currency.balanceOf(mintReferral) +
                currency.balanceOf(admin),
            totalValue
        );
    }

    function test_ERC20MinterCreateReferral() public {
        vm.startPrank(admin);
        uint256 newTokenId = target.setupNewTokenWithCreateReferral("https://zora.co/testing/token.json", 1, createReferral);
        target.addPermission(newTokenId, address(minter), target.PERMISSION_BIT_MINTER());
        vm.stopPrank();

        address targetCreateReferral = minter.getCreateReferral(address(target), newTokenId);
        assertEq(targetCreateReferral, createReferral);

        address fallbackCreateReferral = minter.getCreateReferral(address(this), 1);
        assertEq(fallbackCreateReferral, minterConfig.zoraRewardRecipientAddress);
    }

    function test_ERC20MinterFirstMinterFallback() public {
        uint256 pricePerToken = 1e18;
        uint256 quantity = 11;
        uint256 totalValue = pricePerToken * quantity;

        uint256 tokenId = setUpTargetSale(pricePerToken, fundsRecipient, address(currency), quantity, minter);
        address collector = makeAddr("collector");

        vm.prank(admin);
        currency.mint(collector, totalValue);

        vm.startPrank(collector);
        currency.approve(address(minter), totalValue);
        minter.mint(collector, quantity, address(target), tokenId, totalValue, address(currency), address(0), "");
        vm.stopPrank();

        address firstMinter = minter.getFirstMinter(address(target), tokenId);
        assertEq(firstMinter, admin);

        address fallbackFirstMinter = minter.getFirstMinter(address(this), 1);
        assertEq(fallbackFirstMinter, minterConfig.zoraRewardRecipientAddress);
    }

    function test_ERC20MinterSetZoraRewardsRecipient() public {
        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        IERC20Minter.ERC20MinterConfig memory newConfig = IERC20Minter.ERC20MinterConfig({
            zoraRewardRecipientAddress: address(this),
            rewardRecipientPercentage: TOTAL_REWARD_PCT
        });
        emit ERC20MinterConfigSet(newConfig);
        minter.setERC20MinterConfig(newConfig);

        minterConfig = minter.getERC20MinterConfig();
        assertEq(minterConfig.zoraRewardRecipientAddress, address(this));
    }

    function test_ERC20MinterOnlyRecipientAddressCanSet() public {
        vm.expectRevert(abi.encodeWithSignature("ONLY_OWNER()"));
        IERC20Minter.ERC20MinterConfig memory newConfig = IERC20Minter.ERC20MinterConfig({
            zoraRewardRecipientAddress: address(this),
            rewardRecipientPercentage: TOTAL_REWARD_PCT
        });
        minter.setERC20MinterConfig(newConfig);
    }

    function test_ERC20MinterCannotSetRecipientToZero() public {
        vm.expectRevert(abi.encodeWithSignature("AddressZero()"));
        vm.prank(owner);
        IERC20Minter.ERC20MinterConfig memory newConfig = IERC20Minter.ERC20MinterConfig({
            zoraRewardRecipientAddress: address(0),
            rewardRecipientPercentage: TOTAL_REWARD_PCT
        });
        minter.setERC20MinterConfig(newConfig);
    }

    function test_ERC20SetRewardRecipientPercentage(uint256 percentageFuzz) public {
        vm.assume(percentageFuzz > 0 && percentageFuzz < 100);

        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSignature("InvalidValue()"));
        IERC20Minter.ERC20MinterConfig memory newConfig = IERC20Minter.ERC20MinterConfig({
            zoraRewardRecipientAddress: zora,
            rewardRecipientPercentage: 101
        });
        minter.setERC20MinterConfig(newConfig);

        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        newConfig = IERC20Minter.ERC20MinterConfig({
            zoraRewardRecipientAddress: zora,
            rewardRecipientPercentage: percentageFuzz
        });
        emit ERC20MinterConfigSet(newConfig);
        minter.setERC20MinterConfig(newConfig);
    }

    function test_ERC20MinterSetOwner() public {
        vm.prank(zora);
        vm.expectRevert(abi.encodeWithSignature("ONLY_OWNER()"));
        IERC20Minter.ERC20MinterConfig memory newConfig = IERC20Minter.ERC20MinterConfig({
            zoraRewardRecipientAddress: zora,
            rewardRecipientPercentage: minterConfig.rewardRecipientPercentage
        });
        minter.setERC20MinterConfig(newConfig);

        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        newConfig = IERC20Minter.ERC20MinterConfig({
            zoraRewardRecipientAddress: zora,
            rewardRecipientPercentage: minterConfig.rewardRecipientPercentage
        });
        emit ERC20MinterConfigSet(newConfig);
        minter.setERC20MinterConfig(newConfig);
    }
}
