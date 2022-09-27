// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;

import "../vault/IVault.sol";
import "../liquidity-mining/IBalancerToken.sol";

import "./IBALTokenHolder.sol";

interface IBALTokenHolderFactory {
    function getBalancerToken() external view returns (IBalancerToken);

    function getVault() external view returns (IVault);

    function isHolderFromFactory(address holder) external view returns (bool);

    function create(string memory name) external returns (IBALTokenHolder);
}
