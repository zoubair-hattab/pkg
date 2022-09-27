// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "../../../../solidity-utils/contracts/openzeppelin/Clones.sol";

import "../BaseGaugeFactory.sol";
import "./PolygonRootGauge.sol";

contract PolygonRootGaugeFactory is BaseGaugeFactory {
    constructor(
        IBalancerMinter minter,
        IPolygonRootChainManager polygonRootChainManager,
        address polygonERC20Predicate
    ) BaseGaugeFactory(new PolygonRootGauge(minter, polygonRootChainManager, polygonERC20Predicate)) {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @notice Deploys a new gauge which bridges all of its BAL allowance to a single recipient on Polygon.
     * @dev Care must be taken to ensure that gauges deployed from this factory are
     * suitable before they are added to the GaugeController.
     * @param recipient The address to receive BAL minted from the gauge
     * @param relativeWeightCap The relative weight cap for the created gauge
     * @return The address of the deployed gauge
     */
    function create(address recipient, uint256 relativeWeightCap) external override returns (address) {
        address gauge = _create();
        PolygonRootGauge(gauge).initialize(recipient, relativeWeightCap);
        return gauge;
    }
}
