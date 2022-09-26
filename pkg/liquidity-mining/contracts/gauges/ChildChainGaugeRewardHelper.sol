// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../../../interfaces/contracts/liquidity-mining/IRewardsOnlyGauge.sol";
import "../../../interfaces/contracts/liquidity-mining/IChildChainStreamer.sol";

/**
 * @title ChildChainGaugeRewardHelper
 * @author Balancer Labs
 * @notice Helper contract which allows claiming rewards from many RewardsOnlyGauges in a single transaction.
 * This contract manually triggers an update to the gauges' streamers as a workaround for the gauge .
 */
contract ChildChainGaugeRewardHelper {
    uint256 public constant CLAIM_FREQUENCY = 3600;

    /**
     * @notice Returns the amount of ERC20 token `token` on RewardsOnlyGauge `gauge` claimable by address `user`.
     * @dev This function cannot be marked `view` as it updates the gauge's state (not possible in a view context).
     * Offchain users attempting to read from this function should manually perform a static call or modify the abi.
     * @param gauge - The address of the RewardsOnlyGauge for which to query.
     * @param user - The address of the user for which to query.
     * @param token - The address of the reward token for which to query.
     */
    function getPendingRewards(
        IRewardsOnlyGauge gauge,
        address user,
        address token
    ) external returns (uint256) {
        gauge.reward_contract().get_reward();
        return gauge.claimable_reward_write(user, token);
    }

    /**
     * @notice Claims pending rewards on RewardsOnlyGauge `gauge` for account `user`.
     * @param gauge - The address of the RewardsOnlyGauge from which to claim rewards.
     * @param user - The address of the user for which to claim rewards.
     */
    function claimRewardsFromGauge(IRewardsOnlyGauge gauge, address user) external {
        _claimRewardsFromGauge(gauge, user);
    }

    /**
     * @notice Claims pending rewards on a list of RewardsOnlyGauges `gauges` for account `user`.
     * @param gauges - An array of address of RewardsOnlyGauges from which to claim rewards.
     * @param user - The address of the user for which to claim rewards.
     */
    function claimRewardsFromGauges(IRewardsOnlyGauge[] calldata gauges, address user) external {
        for (uint256 i = 0; i < gauges.length; i++) {
            _claimRewardsFromGauge(gauges[i], user);
        }
    }

    // Internal functions

    function _claimRewardsFromGauge(IRewardsOnlyGauge gauge, address user) internal {
        // Force rewards from the streamer onto the gauge.
        gauge.reward_contract().get_reward();
        gauge.claim_rewards(user);
    }
}
