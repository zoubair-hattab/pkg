// SPDX-License-Identifier: GPL-3.0-or-later
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@balancer-labs/v2-interfaces/contracts/pool-weighted/WeightedPoolUserData.sol";

import "../managed/vendor/BasePool.sol";

contract MockBasePool is BasePool {
    uint256 public constant ON_SWAP_MINIMAL_RETURN = 0xa987654321;
    uint256 public constant ON_SWAP_GENERAL_RETURN = 0x123456789a;
    uint256 public constant ON_JOIN_RETURN = 0xbbaa11;
    uint256 public constant ON_EXIT_RETURN = 0x11aabb;

    using WeightedPoolUserData for bytes;

    bool private _inRecoveryMode;

    event InnerOnInitializePoolCalled(bytes userData);
    event InnerOnSwapMinimalCalled(SwapRequest request, uint256 balanceTokenIn, uint256 balanceTokenOut);
    event InnerOnSwapGeneralCalled(SwapRequest request, uint256[] balances, uint256 indexIn, uint256 indexOut);
    event InnerOnJoinPoolCalled(address sender, uint256[] balances, bytes userData);
    event InnerOnExitPoolCalled(address sender, uint256[] balances, bytes userData);

    constructor(
        IVault vault,
        IVault.PoolSpecialization specialization,
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        address[] memory assetManagers,
        uint256 pauseWindowDuration,
        uint256 bufferPeriodDuration,
        address owner
    )
        BasePool(
            vault,
            specialization,
            name,
            symbol,
            tokens,
            assetManagers,
            pauseWindowDuration,
            bufferPeriodDuration,
            owner
        )
    {}

    function _onInitializePool(address, bytes memory userData) internal override returns (uint256, uint256[] memory) {
        emit InnerOnInitializePoolCalled(userData);

        uint256[] memory amountsIn = userData.initialAmountsIn();
        uint256 bptAmountOut;

        for (uint256 i = 0; i < amountsIn.length; i++) {
            bptAmountOut += amountsIn[i];
        }

        return (bptAmountOut, amountsIn);
    }

    function _onSwapMinimal(
        SwapRequest memory request,
        uint256 balanceTokenIn,
        uint256 balanceTokenOut
    ) internal override returns (uint256) {
        emit InnerOnSwapMinimalCalled(request, balanceTokenIn, balanceTokenOut);
        return ON_SWAP_MINIMAL_RETURN;
    }

    function _onSwapGeneral(
        SwapRequest memory request,
        uint256[] memory balances,
        uint256 indexIn,
        uint256 indexOut
    ) internal override returns (uint256) {
        emit InnerOnSwapGeneralCalled(request, balances, indexIn, indexOut);
        return ON_SWAP_GENERAL_RETURN;
    }

    function _onJoinPool(
        address sender,
        uint256[] memory balances,
        bytes memory userData
    ) internal override returns (uint256, uint256[] memory) {
        emit InnerOnJoinPoolCalled(sender, balances, userData);

        uint256[] memory amountsIn = new uint256[](balances.length);
        for (uint256 i = 0; i < amountsIn.length; ++i) {
            amountsIn[i] = ON_JOIN_RETURN;
        }
        return (0, amountsIn);
    }

    function _onExitPool(
        address sender,
        uint256[] memory balances,
        bytes memory userData
    ) internal override returns (uint256, uint256[] memory) {
        emit InnerOnExitPoolCalled(sender, balances, userData);

        uint256[] memory amountsOut = new uint256[](balances.length);
        for (uint256 i = 0; i < amountsOut.length; ++i) {
            amountsOut[i] = ON_EXIT_RETURN;
        }
        return (0, amountsOut);
    }

    function inRecoveryMode() public view override returns (bool) {
        return _inRecoveryMode;
    }

    function _setRecoveryMode(bool enabled) internal override {
        _inRecoveryMode = enabled;
    }

    function getScalingFactors() external pure override returns (uint256[] memory) {
        revert("Mock method; not implemented");
    }

    function getSwapFeePercentage() external pure override returns (uint256) {
        revert("Mock method; not implemented");
    }

    function payProtocolFees(uint256 bptAmount) public {
        _payProtocolFees(bptAmount);
    }

    function getMinimumBpt() external pure returns (uint256) {
        return _getMinimumBpt();
    }

    function onlyVaultCallable(bytes32 poolId) public view onlyVault(poolId) {
        // solhint-disable-previous-line no-empty-blocks
    }
}
