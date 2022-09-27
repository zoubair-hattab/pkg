// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;

import "./IChildChainStreamer.sol";
import "./IRewardTokenDistributor.sol";

// For compatibility, we're keeping the same function names as in the original Curve code, including the mixed-case
// naming convention.
// solhint-disable func-name-mixedcase

interface IRewardsOnlyGauge is IRewardTokenDistributor {
    function initialize(
        address pool,
        address streamer,
        bytes32 claimSignature
    ) external;

    // solhint-disable-next-line func-name-mixedcase
    function lp_token() external view returns (IERC20);

    function reward_contract() external view returns (IChildChainStreamer);

    function set_rewards(
        address childChainStreamer,
        bytes32 claimSig,
        address[8] calldata rewardTokens
    ) external;

    function last_claim() external view returns (uint256);
}
