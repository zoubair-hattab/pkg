// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;

interface IOptimismGasLimitProvider {
    function getOptimismGasLimit() external view returns (uint32 gasLimit);

    function setOptimismGasLimit(uint32 gasLimit) external;
}
