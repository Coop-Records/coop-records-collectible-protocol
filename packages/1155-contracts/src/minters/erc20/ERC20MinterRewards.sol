// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @notice ERC20Minter Helper contract template
abstract contract ERC20MinterRewards {
    uint256 internal constant MIN_PRICE_PER_TOKEN = 10_000;
    uint256 internal constant BPS_TO_PERCENT_2_DECIMAL_PERCISION = 100;
    uint256 internal constant BPS_TO_PERCENT_8_DECIMAL_PERCISION = 100_000_000;
    uint256 internal constant CREATE_REFERRAL_PAID_MINT_REWARD_PCT = 0; // 0%, no reward for create referral
    uint256 internal constant MINT_REFERRAL_PAID_MINT_REWARD_PCT = 50_000000; // 50%, representing 12.5% of total mint price
    uint256 internal constant ZORA_PAID_MINT_REWARD_PCT = 50_000000; // 50%, representing 12.5% of total mint price
    uint256 internal constant FIRST_MINTER_REWARD_PCT = 0; // 0%, no reward for first minter
}
