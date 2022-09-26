// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.8.0;

interface IArbitrumFeeProvider {
    function getArbitrumFees()
        external
        view
        returns (
            uint256 gasLimit,
            uint256 gasPrice,
            uint256 maxSubmissionCost
        );

    function setArbitrumFees(
        uint64 gasLimit,
        uint64 gasPrice,
        uint64 maxSubmissionCost
    ) external;
}
