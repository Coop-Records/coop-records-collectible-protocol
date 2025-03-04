// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC165Upgradeable} from "@zoralabs/openzeppelin-contracts-upgradeable/contracts/interfaces/IERC165Upgradeable.sol";
import {IERC1155MetadataURIUpgradeable} from "@zoralabs/openzeppelin-contracts-upgradeable/contracts/interfaces/IERC1155MetadataURIUpgradeable.sol";
import {ICoopCreator1155TypesV1} from "../nft/ICoopCreator1155TypesV1.sol";
import {ICoopCreator1155Errors} from "./ICoopCreator1155Errors.sol";
import {IRenderer1155} from "../interfaces/IRenderer1155.sol";
import {IMinter1155} from "../interfaces/IMinter1155.sol";
import {IOwnable} from "../interfaces/IOwnable.sol";
import {IVersionedContract} from "@zoralabs/shared-contracts/interfaces/IVersionedContract.sol";
import {ICreatorRoyaltiesControl} from "../interfaces/ICreatorRoyaltiesControl.sol";
import {IZoraCreator1155DelegatedCreation} from "./IZoraCreator1155DelegatedCreation.sol";
import {IMintWithRewardsRecipients} from "./IMintWithRewardsRecipients.sol";
import {IReduceSupply} from "@zoralabs/shared-contracts/interfaces/IReduceSupply.sol";

/*
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNXK0OkkkkkkO0KXWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNOdl:'...        ...':lx0XWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0d:.                        .:d0NMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMWKd;.                              .;dKWMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMW0l.                                    .l0WMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMNKOkkxkO0KOl.                                        .lKWMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMW0l'.       ..                                            'xNMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMO'   .',,,.                                                .lXMMMMMMMMMMMMMMMMMM
MMMMMMMMMWo   ,0NWWK:                                                  cXMMMMMMMMMMMMMMMMM
MMMMMMMMMMk.  .xWMNo                      .',,,,'.                      oNMMMMMMMMMMMMMMMM
MMMMMMMMMMNo.  .oXx.                  .,oOKNWWWWNKOo,                   .kWMMMMMMMMMMMMMMM
MMMMMMMMMMMNx.   '.                  ,kNMMMMMMMMMMMMNk,                  :XMMMMMMMMMMMMMMM
MMMMMMMMMMMMW0:.                    cXMMMMMMMMMMMMMMMMK:                 .kMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMNk;                  ,0MMMMMMXkddkNMMMMMM0'                 dWMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMNk;                cNMMMMMNo   .oWMMMMMX:                 oWMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMNO:.             ;XMMMMMW0c;;l0WMMMMMK,                 oWMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMW0l'           .dWMMMMMMMWWMMMMMMMNo.                .kMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMNO0WMMXx:.         .oXMMMMMMMMMMMMMMXl.                 ,KMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMWd';xXWMWKd;.        'o0NMMMMMMMWNOo'                  .dWMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMX:  .lONMMW0o,.       .':looool:'.                    .OWMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMM0;    ,o0NMMN0d;.                                     'dNMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMM0;     .,o0NMMWKxc.                               ..   :0WMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMXl.      .,lONWMWXOo;.                         .lK0;   'OWMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMNk,         'cxKWMMWKkl:;.                   ,kWMMXl   ,0MMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMXd'          .,lkXWMMMWKko;..            .oXMMMMM0,  .dWMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMXx;.           .;ok0XWMMWX0xl;..       .,;cclcc,   .kMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMWKd;.            ..;lx0NWMMWX0koc;'..          .;kWMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXko:,..           .'cxKWMMMMMWNK0OxdolllodkKWMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNX0kxolllccllooxk0NWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
*/

/// @notice Main interface for the ZoraCreator1155 contract
/// @author @iainnash / @tbtstl
interface ICoopCreator1155 is
    ICoopCreator1155TypesV1,
    ICoopCreator1155Errors,
    IVersionedContract,
    IOwnable,
    IERC1155MetadataURIUpgradeable,
    IZoraCreator1155DelegatedCreation,
    IMintWithRewardsRecipients,
    IReduceSupply
{
    function PERMISSION_BIT_ADMIN() external returns (uint256);

    /// @notice This user role allows for only mint actions to be performed
    function PERMISSION_BIT_MINTER() external returns (uint256);

    /// @notice This user role allows for only managing sales configurations
    function PERMISSION_BIT_SALES() external returns (uint256);

    /// @notice This user role allows for only managing metadata configuration
    function PERMISSION_BIT_METADATA() external returns (uint256);

    /// @notice This user role allows for only withdrawing funds and setting funds withdraw address
    function PERMISSION_BIT_FUNDS_MANAGER() external returns (uint256);

    /// @notice Used to label the configuration update type
    enum ConfigUpdate {
        OWNER,
        FUNDS_RECIPIENT,
        TRANSFER_HOOK
    }
    event ConfigUpdated(address indexed updater, ConfigUpdate indexed updateType, ContractConfig newConfig);

    event UpdatedToken(address indexed from, uint256 indexed tokenId, TokenData tokenData);
    event SetupNewToken(uint256 indexed tokenId, address indexed sender, string newURI, uint256 maxSupply);

    function setOwner(address newOwner) external;

    function owner() external view returns (address);

    event ContractRendererUpdated(IRenderer1155 renderer);
    event ContractMetadataUpdated(address indexed updater, string uri, string name);
    event Purchased(address indexed sender, address indexed minter, uint256 indexed tokenId, uint256 quantity, uint256 value);

    /// @notice Mint tokens and payout rewards given a minter contract, minter arguments, and rewards arguments
    /// @param minter The minter contract to use
    /// @param tokenId The token ID to mint
    /// @param quantity The quantity of tokens to mint
    /// @param rewardsRecipients The addresses of rewards arguments - rewardsRecipients[0] = mintReferral, rewardsRecipients[1] = platformReferral
    /// @param minterArguments The arguments to pass to the minter
    function mint(IMinter1155 minter, uint256 tokenId, uint256 quantity, address[] calldata rewardsRecipients, bytes calldata minterArguments) external payable;

    function adminMint(address recipient, uint256 tokenId, uint256 quantity, bytes memory data) external;

    function burnBatch(address user, uint256[] calldata tokenIds, uint256[] calldata amounts) external;

    /// @notice Contract call to setupNewToken
    /// @param tokenURI URI for the token
    /// @param maxSupply maxSupply for the token, set to 0 for open edition
    function setupNewToken(string memory tokenURI, uint256 maxSupply) external returns (uint256 tokenId);

    function setupNewTokenWithCreateReferral(string calldata newURI, uint256 maxSupply, address createReferral) external returns (uint256);

    function getCreatorRewardRecipient(uint256 tokenId) external view returns (address);

    function updateTokenURI(uint256 tokenId, string memory _newURI) external;

    function updateContractMetadata(string memory _newURI, string memory _newName) external;

    // Public interface for `setTokenMetadataRenderer(uint256, address) has been deprecated.

    function contractURI() external view returns (string memory);

    function assumeLastTokenIdMatches(uint256 tokenId) external;

    function updateRoyaltiesForToken(uint256 tokenId, ICreatorRoyaltiesControl.RoyaltyConfiguration memory royaltyConfiguration) external;

    /// @notice Set funds recipient address
    /// @param fundsRecipient new funds recipient address
    function setFundsRecipient(address payable fundsRecipient) external;

    /// @notice Allows the create referral to update the address that can claim their rewards
    function updateCreateReferral(uint256 tokenId, address recipient) external;

    function addPermission(uint256 tokenId, address user, uint256 permissionBits) external;

    function removePermission(uint256 tokenId, address user, uint256 permissionBits) external;

    function isAdminOrRole(address user, uint256 tokenId, uint256 role) external view returns (bool);

    function getTokenInfo(uint256 tokenId) external view returns (TokenData memory);

    function callRenderer(uint256 tokenId, bytes memory data) external;

    function callSale(uint256 tokenId, IMinter1155 salesConfig, bytes memory data) external;

    function mintFee() external view returns (uint256);

    /// @notice Withdraws all ETH from the contract to the funds recipient address
    function withdraw() external;

    /// @notice Returns the current implementation address
    function implementation() external view returns (address);
}
