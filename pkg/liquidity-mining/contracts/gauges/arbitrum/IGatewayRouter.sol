// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.8.0;

import "../../../../interfaces/contracts/solidity-utils/openzeppelin/IERC20.sol";

interface IGatewayRouter {
    function outboundTransfer(
        IERC20 token,
        address recipient,
        uint256 amount,
        uint256 gasLimit,
        uint256 gasPrice,
        bytes calldata data
    ) external payable;

    function getGateway(address token) external view returns (address gateway);
}
