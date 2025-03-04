// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Initializable} from "@zoralabs/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@zoralabs/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {ICoopCreator1155Factory} from "../interfaces/ICoopCreator1155Factory.sol";
import {ICoopCreator1155Initializer} from "../interfaces/ICoopCreator1155Initializer.sol";
import {ICoopCreator1155} from "../interfaces/ICoopCreator1155.sol";
import {ICreatorRoyaltiesControl} from "../interfaces/ICreatorRoyaltiesControl.sol";
import {IMinter1155} from "../interfaces/IMinter1155.sol";
import {IContractMetadata} from "../interfaces/IContractMetadata.sol";
import {Ownable2StepUpgradeable} from "../utils/ownable/Ownable2StepUpgradeable.sol";
import {Coop1155} from "../proxies/Coop1155.sol";
import {Create2Upgradeable} from "@zoralabs/openzeppelin-contracts-upgradeable/contracts/utils/Create2Upgradeable.sol";
import {CREATE3} from "solmate/src/utils/CREATE3.sol";

import {ContractVersionBase} from "../version/ContractVersionBase.sol";

/// @title CoopCreator1155FactoryImpl
/// @notice Factory contract for creating new CoopCreator1155 contracts
contract CoopCreator1155FactoryImpl is ICoopCreator1155Factory, Ownable2StepUpgradeable, ContractVersionBase, UUPSUpgradeable, IContractMetadata {
    ICoopCreator1155 public immutable zora1155Impl;
    IMinter1155 public immutable merkleMinter;
    IMinter1155 public immutable fixedPriceMinter;
    IMinter1155 public immutable redeemMinterFactory;

    constructor(ICoopCreator1155 _zora1155Impl, IMinter1155 _merkleMinter, IMinter1155 _fixedPriceMinter, IMinter1155 _redeemMinterFactory) initializer {
        if (address(_zora1155Impl) == address(0)) {
            revert Constructor_ImplCannotBeZero();
        }
        zora1155Impl = _zora1155Impl;
        merkleMinter = _merkleMinter;
        fixedPriceMinter = _fixedPriceMinter;
        redeemMinterFactory = _redeemMinterFactory;
    }

    /// @notice ContractURI for contract information with the strategy
    function contractURI() external pure returns (string memory) {
        return "https://github.com/ourzora/zora-1155-contracts/";
    }

    /// @notice The name of the sale strategy
    function contractName() external pure returns (string memory) {
        return "COOP 1155 Contract Factory";
    }

    /// @notice The default minters for new 1155 contracts
    function defaultMinters() external view returns (IMinter1155[] memory minters) {
        minters = new IMinter1155[](3);
        minters[0] = fixedPriceMinter;
        minters[1] = merkleMinter;
        minters[2] = redeemMinterFactory;
    }

    function initialize(address _initialOwner) public initializer {
        __Ownable_init(_initialOwner);
        __UUPSUpgradeable_init();

        emit FactorySetup();
    }

    /// @notice Creates a new CoopCreator1155 contract
    /// @param newContractURI The URI for the contract metadata
    /// @param name The name of the contract
    /// @param defaultRoyaltyConfiguration The default royalty configuration for the contract
    /// @param defaultAdmin The default admin for the contract
    /// @param setupActions The actions to perform on the new contract upon initialization
    function createContract(
        string calldata newContractURI,
        string calldata name,
        ICreatorRoyaltiesControl.RoyaltyConfiguration memory defaultRoyaltyConfiguration,
        address payable defaultAdmin,
        bytes[] calldata setupActions
    ) external returns (address) {
        Coop1155 newContract = new Coop1155(address(zora1155Impl));

        _initializeContract(Coop1155(newContract), newContractURI, name, defaultRoyaltyConfiguration, defaultAdmin, setupActions);

        return address(newContract);
    }

    function createContractDeterministic(
        string calldata newContractURI,
        string calldata name,
        ICreatorRoyaltiesControl.RoyaltyConfiguration calldata defaultRoyaltyConfiguration,
        address payable defaultAdmin,
        bytes[] calldata setupActions
    ) public override returns (address) {
        bytes32 digest = _hashContract(msg.sender, newContractURI, name, defaultAdmin, _setupActionsSalt(setupActions));

        address createdContract = CREATE3.deploy(digest, abi.encodePacked(type(Coop1155).creationCode, abi.encode(zora1155Impl)), 0);

        Coop1155 newContract = Coop1155(payable(createdContract));

        _initializeContract(newContract, newContractURI, name, defaultRoyaltyConfiguration, defaultAdmin, setupActions);

        return address(newContract);
    }

    /// @notice Get or create new contract deterministic
    /// @param expectedContractAddress Optional: set the expected contract address for this deployment, set to 0 to skip check
    /// @param newContractURI new contract uri for the deploy
    /// @param name contract name
    /// @param defaultRoyaltyConfiguration royalty configuration
    /// @param defaultAdmin default admin
    /// @param setupActions setup actions array
    function getOrCreateContractDeterministic(
        address expectedContractAddress,
        string calldata newContractURI,
        string calldata name,
        ICreatorRoyaltiesControl.RoyaltyConfiguration calldata defaultRoyaltyConfiguration,
        address payable defaultAdmin,
        bytes[] calldata setupActions
    ) external override returns (address calculatedContractAddress) {
        calculatedContractAddress = deterministicContractAddressWithSetupActions(msg.sender, newContractURI, name, defaultAdmin, setupActions);
        if (expectedContractAddress != address(0) && expectedContractAddress != calculatedContractAddress) {
            revert ExpectedContractAddressDoesNotMatchCalculatedContractAddress(expectedContractAddress, calculatedContractAddress);
        }
        if (calculatedContractAddress.code.length > 0) {
            emit ContractAlreadyExistsSkippingDeploy(calculatedContractAddress);
        } else {
            createContractDeterministic(newContractURI, name, defaultRoyaltyConfiguration, defaultAdmin, setupActions);
        }
    }

    function deterministicContractAddress(
        address msgSender,
        string calldata newContractURI,
        string calldata name,
        address contractAdmin
    ) external view override returns (address) {
        return deterministicContractAddressWithSetupActions(msgSender, newContractURI, name, contractAdmin, new bytes[](0));
    }

    function _setupActionsSalt(bytes[] memory setupActions) private pure returns (bytes32) {
        return setupActions.length == 0 ? bytes32(0) : keccak256(abi.encode(setupActions));
    }

    function deterministicContractAddressWithSetupActions(
        address msgSender,
        string calldata newContractURI,
        string calldata name,
        address contractAdmin,
        bytes[] memory setupActions
    ) public view override returns (address) {
        bytes32 digest = _hashContract(msgSender, newContractURI, name, contractAdmin, _setupActionsSalt(setupActions));

        return CREATE3.getDeployed(digest);
    }

    function _initializeContract(
        Coop1155 newContract,
        string calldata newContractURI,
        string calldata name,
        ICreatorRoyaltiesControl.RoyaltyConfiguration memory defaultRoyaltyConfiguration,
        address payable defaultAdmin,
        bytes[] calldata setupActions
    ) private {
        emit SetupNewContract({
            newContract: address(newContract),
            creator: msg.sender,
            defaultAdmin: defaultAdmin,
            contractURI: newContractURI,
            name: name,
            defaultRoyaltyConfiguration: defaultRoyaltyConfiguration
        });

        ICoopCreator1155Initializer(address(newContract)).initialize(name, newContractURI, defaultRoyaltyConfiguration, defaultAdmin, setupActions);
    }

    function _hashContract(
        address msgSender,
        string calldata newContractURI,
        string calldata name,
        address contractAdmin,
        bytes32 salt
    ) private pure returns (bytes32) {
        // salt is a newer feature; prior to adding a salt, it wasn't part of the hash.
        // so this special case is needed to maintain backwards compatibility
        if (salt == bytes32(0)) {
            return keccak256(abi.encode(msgSender, contractAdmin, _stringHash(newContractURI), _stringHash(name)));
        }

        return keccak256(abi.encode(msgSender, contractAdmin, _stringHash(newContractURI), _stringHash(name), salt));
    }

    function _stringHash(string calldata value) private pure returns (bytes32) {
        return keccak256(bytes(value));
    }

    ///                                                          ///
    ///                         MANAGER UPGRADE                  ///
    ///                                                          ///

    /// @notice Ensures the caller is authorized to upgrade the contract
    /// @dev This function is called in `upgradeTo` & `upgradeToAndCall`
    /// @param _newImpl The new implementation address
    function _authorizeUpgrade(address _newImpl) internal override onlyOwner {
        if (!_equals(IContractMetadata(_newImpl).contractName(), this.contractName())) {
            revert UpgradeToMismatchedContractName(this.contractName(), IContractMetadata(_newImpl).contractName());
        }
    }

    /// @notice Returns the current implementation address
    function implementation() external view returns (address) {
        return _getImplementation();
    }

    function _equals(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(bytes(a)) == keccak256(bytes(b)));
    }
}
