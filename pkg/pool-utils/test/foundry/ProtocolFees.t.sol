// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "forge-std/Test.sol";

import "../../../solidity-utils/contracts/math/FixedPoint.sol";

import "../../contracts/protocol-fees/ProtocolFees.sol";

contract ProtocolFeesTest is Test {
    function testNoPercentage(uint128 totalSupply) external {
        assertEq(ProtocolFees.bptForPoolOwnershipPercentage(totalSupply, 0), 0);
    }

    function testNoSupply(uint64 expectedOwnershipPercentage) external {
        vm.assume(expectedOwnershipPercentage < 1e18);
        assertEq(ProtocolFees.bptForPoolOwnershipPercentage(0, expectedOwnershipPercentage), 0);
    }

    function testPostOwnershipPercentage(uint128 totalSupply, uint64 expectedOwnershipPercentage) external {
        vm.assume(totalSupply > 1e6);
        vm.assume(expectedOwnershipPercentage < 1e18);
        uint256 fees = ProtocolFees.bptForPoolOwnershipPercentage(totalSupply, expectedOwnershipPercentage);

        // Ownership of the fees should result in overall Pool ownership at least as large as the expected one (it may
        // be lower due to rounding errors that favor the other LPs).
        uint256 actualOwnershipPercentage = FixedPoint.divDown(fees, fees + totalSupply);
        assertLe(actualOwnershipPercentage, expectedOwnershipPercentage);

        // If we minted just one more token, the recipient of the fees would have ownership of the Pool no smaller than
        // the expected value (potentially equal in extreme rounding cases), meaning we're not rounding down
        // excessively.
        uint256 largerActualOwnershipPercentage = FixedPoint.divDown((fees + 1), (fees + 1) + totalSupply);
        assertGe(largerActualOwnershipPercentage, expectedOwnershipPercentage);
    }
}
