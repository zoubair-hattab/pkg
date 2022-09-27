// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.7.0;

import "../../../../solidity-utils/contracts/openzeppelin/SafeERC20.sol";

import "../StakelessGauge.sol";

contract SingleRecipientGauge is StakelessGauge {
    using SafeERC20 for IERC20;

    address private _recipient;

    constructor(IBalancerMinter minter) StakelessGauge(minter) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function initialize(address recipient, uint256 relativeWeightCap) external {
        // This will revert in all calls except the first one
        __StakelessGauge_init(relativeWeightCap);

        _recipient = recipient;
    }

    function getRecipient() external view override returns (address) {
        return _recipient;
    }

    function _postMintAction(uint256 mintAmount) internal override {
        _balToken.safeTransfer(_recipient, mintAmount);
    }
}
