// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.8.0;

import "../solidity-utils/openzeppelin/IERC20.sol";

import "./IButtonWrapper.sol";

// Balancer only supports ERC20 tokens, so we use this intermediate interface
// to enforce ERC20-ness of UnbuttonTokens.
interface IUnbuttonToken is IButtonWrapper, IERC20 {
    // solhint-disable-previous-line no-empty-blocks
}
