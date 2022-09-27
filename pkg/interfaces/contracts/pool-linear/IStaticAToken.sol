// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;

import "./ILendingPool.sol";

interface IStaticAToken {
    /**
     * @dev returns the address of the staticAToken's underlying asset
     */
    // solhint-disable-next-line func-name-mixedcase
    function ASSET() external view returns (address);

    /**
     * @dev returns the address of the staticAToken's lending pool
     */
    // solhint-disable-next-line func-name-mixedcase
    function LENDING_POOL() external view returns (ILendingPool);

    /**
     * @dev returns a 27 decimal fixed point 'ray' value so a rate of 1 is represented as 1e27
     */
    function rate() external view returns (uint256);

    function deposit(
        address,
        uint256,
        uint16,
        bool
    ) external returns (uint256);

    function withdraw(
        address,
        uint256,
        bool
    ) external returns (uint256, uint256);

    function staticToDynamicAmount(uint256 amount) external view returns (uint256);
}
