// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../solidity-utils/openzeppelin/IERC20.sol";

// For compatibility, we're keeping the same function names as in the original Curve code, including the mixed-case
// naming convention.
// solhint-disable func-name-mixedcase, var-name-mixedcase

interface IRewardTokenDistributor {
    struct Reward {
        IERC20 token;
        address distributor;
        uint256 period_finish;
        uint256 rate;
        uint256 last_update;
        uint256 integral;
    }

    function reward_tokens(uint256 index) external view returns (IERC20);

    function reward_data(IERC20 token) external view returns (Reward memory);

    function claim_rewards(address user) external;

    function add_reward(IERC20 rewardToken, address distributor) external;

    function set_reward_distributor(IERC20 rewardToken, address distributor) external;

    function deposit_reward_token(IERC20 rewardToken, uint256 amount) external;

    function claimable_reward(address rewardToken, address user) external view returns (uint256);

    function claimable_reward_write(address rewardToken, address user) external returns (uint256);
}
