// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/*


             ░░░░░░░░░░░░░░              
        ░░▒▒░░░░░░░░░░░░░░░░░░░░        
      ░░▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░      
    ░░▒▒▒▒░░░░░░░░░░░░░░    ░░░░░░░░    
   ░▓▓▒▒▒▒░░░░░░░░░░░░        ░░░░░░░    
  ░▓▓▓▒▒▒▒░░░░░░░░░░░░        ░░░░░░░░  
  ░▓▓▓▒▒▒▒░░░░░░░░░░░░░░    ░░░░░░░░░░  
  ░▓▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░  
  ░▓▓▓▓▓▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░  
   ░▓▓▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░  
    ░░▓▓▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░    
    ░░▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░░▒▒▒▒▒░░    
      ░░▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░      
          ░░▓▓▓▓▓▓▓▓▓▓▓▓▒▒░░░          

               OURS TRULY,


*/

/// @title Coop Timed Sale Strategy Constants
/// @notice Sale strategy constants
/// @author @sweetman @isabellasmallcombe @kulkarohan
contract ZoraTimedSaleStrategyConstants {
    /// @notice The mint price for each token
    uint256 internal constant MINT_PRICE = 0.0004 ether;
    /// @notice The creator reward
    uint256 internal constant CREATOR_REWARD = 0.0002 ether;
    /// @notice The mint referrer reward
    uint256 internal constant MINT_REFERRER_REWARD = 0.00004 ether;
    /// @notice The creator referrer reward
    uint256 internal constant CREATOR_REFERRER_REWARD = 0 ether;
    /// @notice The amount of ETH from each mint that is reserved for the secondary market liquidity pool.
    ///         For V2 sales, this is also the lowest amount that can be passed for `minimumMarketEth`,
    ///         as it ensures that a secondary market can always begin with one whole unit.
    uint256 internal constant MARKET_REWARD = 0.0001 ether;
    /// @notice The Zora reward
    uint256 internal constant ZORA_REWARD = 0.00006 ether;
    /// @notice 1e18
    uint256 internal constant ONE_ERC_20 = 1e18;
}