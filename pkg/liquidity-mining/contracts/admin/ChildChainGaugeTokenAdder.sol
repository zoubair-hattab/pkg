// SPDX-License-Identifier: GPL-3.0-or-later
// This program is free software: you can redistribute it and/or modify


pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "../../../interfaces/contracts/liquidity-mining/IChildChainLiquidityGaugeFactory.sol";
import "../../../interfaces/contracts/liquidity-mining/IAuthorizerAdaptor.sol";

import "../../../solidity-utils/contracts/helpers/SingletonAuthentication.sol";

/**
 * @title ChildChainGaugeTokenAdder
 * @notice Allows atomically adding a new reward token to a RewardsOnlyGauge while ensuring that it remains in sync
 * with its ChildChainStreamer.
 */
contract ChildChainGaugeTokenAdder is SingletonAuthentication {
    // RewardsOnlyGauge expects the claim function selector to be left padded with zeros.
    // We then shift right 28 bytes so that the function selector (top 4 bytes) sits in the lowest 4 bytes.
    bytes32 private constant _CLAIM_SIG = keccak256("get_reward()") >> (28 * 8);
    uint256 private constant _MAX_TOKENS = 8;
    uint256 private constant _REWARD_DURATION = 1 weeks;

    IAuthorizerAdaptor private immutable _authorizerAdaptor;
    IChildChainLiquidityGaugeFactory private immutable _gaugeFactory;

    constructor(IChildChainLiquidityGaugeFactory gaugeFactory, IAuthorizerAdaptor authorizerAdaptor)
        SingletonAuthentication(authorizerAdaptor.getVault())
    {
        _authorizerAdaptor = authorizerAdaptor;
        _gaugeFactory = gaugeFactory;
    }

    /**
     * @notice Returns the address of the Authorizer adaptor contract.
     */
    function getAuthorizerAdaptor() external view returns (IAuthorizerAdaptor) {
        return _authorizerAdaptor;
    }

    /**
     * @notice Adds a new token to a RewardsOnlyGauge.
     */
    function addTokenToGauge(
        IRewardsOnlyGauge gauge,
        IERC20 rewardToken,
        address distributor
    ) external authenticate {
        require(_gaugeFactory.isGaugeFromFactory(address(gauge)), "Invalid gauge");
        IChildChainStreamer streamer = IChildChainStreamer(_gaugeFactory.getGaugeStreamer(address(gauge)));
        require(streamer == gauge.reward_contract(), "Not original gauge streamer");

        // We first add the new token to the streamer so that the gauge can claim it when checkpointing.
        _addTokenToStreamer(streamer, rewardToken, distributor);

        // We must pass the full list of tokens which the gauge should claim from the streamer when adding a new token.
        // We then query this from the streamer to ensure that the reward tokens on each contract are consistent.
        // As we have added the new reward token to the streamer already, this array will include it.
        IERC20[_MAX_TOKENS] memory rewardTokens;
        for (uint256 i; i < _MAX_TOKENS; ++i) {
            rewardTokens[i] = streamer.reward_tokens(i);
        }

        // We now let the gauge know to claim the new token.
        _updateGaugeRewardTokens(gauge, streamer, rewardTokens);
    }

    function _addTokenToStreamer(
        IChildChainStreamer streamer,
        IERC20 rewardToken,
        address distributor
    ) private {
        _authorizerAdaptor.performAction(
            address(streamer),
            abi.encodeWithSelector(IChildChainStreamer.add_reward.selector, rewardToken, distributor, _REWARD_DURATION)
        );
    }

    function _updateGaugeRewardTokens(
        IRewardsOnlyGauge gauge,
        IChildChainStreamer streamer,
        IERC20[_MAX_TOKENS] memory rewardTokens
    ) private {
        _authorizerAdaptor.performAction(
            address(gauge),
            abi.encodeWithSelector(IRewardsOnlyGauge.set_rewards.selector, streamer, _CLAIM_SIG, rewardTokens)
        );
    }
}
