// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../../../../solidity-utils/contracts/helpers/SingletonAuthentication.sol";
import "../../../../solidity-utils/contracts/openzeppelin/Clones.sol";

import "../BaseGaugeFactory.sol";
import "./OptimismRootGauge.sol";

contract OptimismRootGaugeFactory is IOptimismGasLimitProvider, BaseGaugeFactory, SingletonAuthentication {
    uint32 private _gasLimit;

    event OptimismGasLimitModified(uint256 gasLimit);

    constructor(
        IVault vault,
        IBalancerMinter minter,
        IL1StandardBridge optimismL1StandardBridge,
        address optimismBal,
        uint32 gasLimit
    )
        BaseGaugeFactory(new OptimismRootGauge(minter, optimismL1StandardBridge, optimismBal))
        SingletonAuthentication(vault)
    {
        _gasLimit = gasLimit;
    }

    /**
     * @notice Returns the gas limit for the Optimism side of the bridging transaction
     */
    function getOptimismGasLimit() external view override returns (uint32) {
        return _gasLimit;
    }

    /**
     * @notice Deploys a new gauge which bridges all of its BAL allowance to a single recipient on Optimism.
     * @dev Care must be taken to ensure that gauges deployed from this factory are
     * suitable before they are added to the GaugeController.
     * @param recipient The address to receive BAL minted from the gauge
     * @param relativeWeightCap The relative weight cap for the created gauge
     * @return The address of the deployed gauge
     */
    function create(address recipient, uint256 relativeWeightCap) external override returns (address) {
        address gauge = _create();
        OptimismRootGauge(gauge).initialize(recipient, relativeWeightCap);
        return gauge;
    }

    /**
     * @notice Set the gas limit for the Optimism side of the bridging transaction
     */
    function setOptimismGasLimit(uint32 gasLimit) external override authenticate {
        _gasLimit = gasLimit;
        emit OptimismGasLimitModified(gasLimit);
    }
}
