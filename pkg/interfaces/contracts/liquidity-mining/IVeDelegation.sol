// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.8.0;

// For compatibility, we're keeping the same function names as in the original Curve code, including the mixed-case
// naming convention.
// solhint-disable func-name-mixedcase

interface IVeDelegation {
    // solhint-disable-next-line func-name-mixedcase
    function adjusted_balance_of(address user) external view returns (uint256);
}
