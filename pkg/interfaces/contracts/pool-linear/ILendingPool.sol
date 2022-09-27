// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;

interface ILendingPool {
    /**
     * @dev returns a 27 decimal fixed point 'ray' value so a rate of 1 is represented as 1e27
     */
    function getReserveNormalizedIncome(address asset) external view returns (uint256);
}
