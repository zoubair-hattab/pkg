// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./IBasePoolFactory.sol";

interface ILastCreatedPoolFactory is IBasePoolFactory {
    /**
     * @dev Returns the address of the last Pool created by this factory.
     *
     * This is typically only useful in complex Pool deployment schemes, where multiple subsystems need to know about
     * each other. Note that this value will only be updated once construction of the last created Pool finishes.
     */
    function getLastCreatedPool() external view returns (address);
}
