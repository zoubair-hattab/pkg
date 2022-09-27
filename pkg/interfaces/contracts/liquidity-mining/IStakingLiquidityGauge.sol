// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "../solidity-utils/openzeppelin/IERC20.sol";

import "./ILiquidityGauge.sol";
import "./IRewardTokenDistributor.sol";

// For compatibility, we're keeping the same function names as in the original Curve code, including the mixed-case
// naming convention.
// solhint-disable func-name-mixedcase, var-name-mixedcase

interface IStakingLiquidityGauge is IRewardTokenDistributor, ILiquidityGauge, IERC20 {
    function initialize(address lpToken, uint256 relativeWeightCap) external;

    function lp_token() external view returns (IERC20);

    function deposit(uint256 value, address recipient) external;

    function withdraw(uint256 value) external;
}
