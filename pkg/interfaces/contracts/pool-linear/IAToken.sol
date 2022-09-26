// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.8.0;

interface IAToken {
    /**
     * @dev returns the address of the aToken's underlying asset
     */
    // solhint-disable-next-line func-name-mixedcase
    function UNDERLYING_ASSET_ADDRESS() external view returns (address);
}
