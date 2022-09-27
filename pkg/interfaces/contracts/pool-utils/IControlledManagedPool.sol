// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;

import "./IControlledPool.sol";

interface IControlledManagedPool {
    function setSwapFeePercentage(uint256 swapFeePercentage) external;

    function updateWeightsGradually(
        uint256 startTime,
        uint256 endTime,
        uint256[] calldata endWeights
    ) external;

    function setSwapEnabled(bool swapEnabled) external;

    function addAllowedAddress(address member) external;

    function removeAllowedAddress(address member) external;

    function setMustAllowlistLPs(bool mustAllowlistLPs) external;

    function collectAumManagementFees() external returns (uint256);

    function setManagementAumFeePercentage(uint256 managementAumFeePercentage) external returns (uint256);
}
