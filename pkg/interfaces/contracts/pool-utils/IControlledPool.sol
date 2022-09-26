// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.8.0;

import "../solidity-utils/openzeppelin/IERC20.sol";

interface IControlledPool {
    function setSwapFeePercentage(uint256 swapFeePercentage) external;
}
