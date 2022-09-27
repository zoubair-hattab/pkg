// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;

interface ISmartWalletChecker {
    function check(address contractAddress) external view returns (bool);
}
