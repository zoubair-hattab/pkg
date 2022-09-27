// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;

import "../../../interfaces/contracts/liquidity-mining/IBaseGaugeFactory.sol";
import "../../../interfaces/contracts/liquidity-mining/ILiquidityGauge.sol";

import "../../../solidity-utils/contracts/openzeppelin/Clones.sol";

abstract contract BaseGaugeFactory is IBaseGaugeFactory {
    ILiquidityGauge private _gaugeImplementation;

    mapping(address => bool) private _isGaugeFromFactory;

    event GaugeCreated(address indexed gauge);

    constructor(ILiquidityGauge gaugeImplementation) {
        _gaugeImplementation = gaugeImplementation;
    }

    /**
     * @notice Returns the address of the implementation used for gauge deployments.
     */
    function getGaugeImplementation() public view returns (ILiquidityGauge) {
        return _gaugeImplementation;
    }

    /**
     * @notice Returns true if `gauge` was created by this factory.
     */
    function isGaugeFromFactory(address gauge) external view override returns (bool) {
        return _isGaugeFromFactory[gauge];
    }

    /**
     * @dev Deploys a new gauge as a proxy of the implementation in storage.
     * The deployed gauge must be initialized by the caller method.
     * @return The address of the deployed gauge
     */
    function _create() internal returns (address) {
        address gauge = Clones.clone(address(_gaugeImplementation));

        _isGaugeFromFactory[gauge] = true;
        emit GaugeCreated(gauge);

        return gauge;
    }
}
