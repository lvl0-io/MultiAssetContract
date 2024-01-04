// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/MultiAssetContract.sol"; // Replace with the path to your contract

contract MultiAssetContractTest is Test {
    MultiAssetContract multiAssetContract;
    address owner;

    function setUp() public {
        owner = address(this);
        multiAssetContract = new MultiAssetContract();
        vm.startPrank(owner);
        vm.deal(owner, 1 ether);
    }

    receive() external payable {
        //emit Received(msg.sender, msg.value);
    }

    function testGetOwner() public {
        address expectedOwner = multiAssetContract.getOwner();
        assertEq(
            owner,
            expectedOwner,
            "Owner address does not match expected owner"
        );
    }

    function testReceive() public {
        // Assert that the contract has received the Ether
        assertEq(address(multiAssetContract).balance, 0);

        // Send Ether to the contract
        payable(address(multiAssetContract)).transfer(1e18);

        // Assert that the contract has received the Ether
        assertEq(address(multiAssetContract).balance, 1e18);
    }

    function testWithdraw() public {
        // Deploy the contract and ensure test account is owner
        uint256 depositAmount = 1 ether;
        payable(address(multiAssetContract)).transfer(depositAmount);

        // Check initial balances
        uint256 initialContractBalance = address(multiAssetContract).balance;
        uint256 initialOwnerBalance = owner.balance;

        // Perform the withdrawal
        uint256 withdrawAmount = 0.5 ether;
        multiAssetContract.withdraw(withdrawAmount);

        // Check final balances
        assertEq(
            address(multiAssetContract).balance,
            initialContractBalance - withdrawAmount
        );
        assertEq(owner.balance, initialOwnerBalance + withdrawAmount);
    }
}
