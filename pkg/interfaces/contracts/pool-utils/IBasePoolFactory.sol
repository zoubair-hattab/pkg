// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../solidity-utils/helpers/IAuthentication.sol";

interface IBasePoolFactory is IAuthentication {
    /**
     * @dev Returns true if `pool` was created by this factory.
     */
    function isPoolFromFactory(address pool) external view returns (bool);

    /**
     * @dev Check whether the derived factory has been disabled.
     */
    function isDisabled() external view returns (bool);

    /**
     * @dev Disable the factory, preventing the creation of more pools. Already existing pools are unaffected.
     * Once a factory is disabled, it cannot be re-enabled.
     */
    function disable() external;
}
