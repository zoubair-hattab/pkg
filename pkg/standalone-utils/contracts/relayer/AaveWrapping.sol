// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../../../interfaces/contracts/standalone-utils/IStaticATokenLM.sol";
import "../../../interfaces/contracts/vault/IVault.sol";

import "../../../solidity-utils/contracts/openzeppelin/Address.sol";

import "./IBaseRelayerLibrary.sol";

/**
 * @title AaveWrapping
 * @notice Allows users to wrap and unwrap Aave's aTokens into their StaticAToken wrappers
 * @dev All functions must be payable so they can be called from a multicall involving ETH
 */
abstract contract AaveWrapping is IBaseRelayerLibrary {
    using Address for address payable;

    function wrapAaveDynamicToken(
        IStaticATokenLM staticToken,
        address sender,
        address recipient,
        uint256 amount,
        bool fromUnderlying,
        uint256 outputReference
    ) external payable {
        if (_isChainedReference(amount)) {
            amount = _getChainedReferenceValue(amount);
        }

        // Aave's StaticATokens allow wrapping either an aToken or the underlying asset.
        // We can query which token to pull and approve from the wrapper contract.
        IERC20 dynamicToken = fromUnderlying ? staticToken.ASSET() : staticToken.ATOKEN();

        // The wrap caller is the implicit sender of tokens, so if the goal is for the tokens
        // to be sourced from outside the relayer, we must first pull them here.
        if (sender != address(this)) {
            require(sender == msg.sender, "Incorrect sender");
            _pullToken(sender, dynamicToken, amount);
        }

        dynamicToken.approve(address(staticToken), amount);
        // Use 0 for the referral code
        uint256 result = staticToken.deposit(recipient, amount, 0, fromUnderlying);

        if (_isChainedReference(outputReference)) {
            _setChainedReferenceValue(outputReference, result);
        }
    }

    function unwrapAaveStaticToken(
        IStaticATokenLM staticToken,
        address sender,
        address recipient,
        uint256 amount,
        bool toUnderlying,
        uint256 outputReference
    ) external payable {
        if (_isChainedReference(amount)) {
            amount = _getChainedReferenceValue(amount);
        }

        // The unwrap caller is the implicit sender of tokens, so if the goal is for the tokens
        // to be sourced from outside the relayer, we must first pull them here.
        if (sender != address(this)) {
            require(sender == msg.sender, "Incorrect sender");
            _pullToken(sender, staticToken, amount);
        }

        // No approval is needed here, as the Static Tokens are burned directly from the relayer's account
        (, uint256 result) = staticToken.withdraw(recipient, amount, toUnderlying);

        if (_isChainedReference(outputReference)) {
            _setChainedReferenceValue(outputReference, result);
        }
    }
}
