// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.7.0;

import "../solidity-utils/helpers/IAuthentication.sol";
import "../solidity-utils/openzeppelin/IERC20.sol";

interface IBALTokenHolder is IAuthentication {
    function getName() external view returns (string memory);

    function withdrawFunds(address recipient, uint256 amount) external;

    function sweepTokens(
        IERC20 token,
        address recipient,
        uint256 amount
    ) external;
}
