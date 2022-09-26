// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../../../../interfaces/contracts/liquidity-mining/IStakelessGauge.sol";

import "../../../../solidity-utils/contracts/openzeppelin/Clones.sol";

import "../BaseGaugeFactory.sol";
import "./SingleRecipientGauge.sol";

contract SingleRecipientGaugeFactory is BaseGaugeFactory {
    constructor(IBalancerMinter minter) BaseGaugeFactory(new SingleRecipientGauge(minter)) {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @notice Deploys a new gauge which sends all of its BAL allowance to a single recipient.
     * @dev Care must be taken to ensure that gauges deployed from this factory are
     * suitable before they are added to the GaugeController.
     * @param recipient The address to receive BAL minted from the gauge
     * @param relativeWeightCap The relative weight cap for the created gauge
     * @return The address of the deployed gauge
     */
    function create(address recipient, uint256 relativeWeightCap) external override returns (address) {
        address gauge = _create();
        SingleRecipientGauge(gauge).initialize(recipient, relativeWeightCap);
        return gauge;
    }
}
