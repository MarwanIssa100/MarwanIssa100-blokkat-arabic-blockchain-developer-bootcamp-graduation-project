// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/SparkUp.sol";

contract SparkUpTest is Test {
    SparkUp public sparkUp;
    address user = makeAddr("user");
    address fundraiser = makeAddr("fundraiser");


    function setUp() public {
        vm.startPrank(user);
        sparkUp = new SparkUp();
        vm.stopPrank();
        vm.deal(fundraiser, 10 ether);
    }


    function test_createIdea() public {
        // Tests idea creation with valid parameters
        // Verifies all idea fields are stored correctly including owner and deadline

        vm.startPrank(fundraiser);
        sparkUp.createIdea("Idea 1", "Description 1" , 1000, block.timestamp + 7 days);

        (string memory storedTitle, string memory storedDescription, address owner, uint256 fundGoal,
        uint256 storedDeadline, uint256 amountCollected, bool completed) = sparkUp.getIdea(1);

        assertEq(storedTitle, "Idea 1");
        assertEq(storedDescription, "Description 1");
        assertEq(owner, fundraiser);
        assertEq(fundGoal, 1000);
        assertEq(storedDeadline, block.timestamp + 7 days);
        assertEq(amountCollected, 0);
        assertEq(completed, false);

        vm.stopPrank();
    }

    function test_FundIdea() public {
        // Tests funding an idea with ETH
        // Verifies the collected amount updates correctly
        vm.startPrank(fundraiser);
        sparkUp.createIdea("Idea 1", "Description 1" , 2 ether, block.timestamp + 7 days);
        sparkUp.fundIdea{value: 2 ether}(1);
        (string memory storedTitle, string memory storedDescription, address owner, uint256 fundGoal,
        uint256 storedDeadline, uint256 amountCollected, bool completed) = sparkUp.getIdea(1);
        assertEq(amountCollected, 2 ether);
        vm.stopPrank();
    }

    function test_withdraw() public {
        // Tests owner withdrawing funds from funded idea
        // Should leave 5% fee in contract (verified in other test)
        vm.deal(user, 10 ether);
        vm.startPrank(user);
        sparkUp.createIdea("Idea 1", "Description 1" , 2 ether, block.timestamp + 7 days);
        sparkUp.fundIdea{value: 2 ether}(1);

        uint256 contractBalanceBefore = address(sparkUp).balance;
        uint256 ownerBalanceBefore = user.balance;

        sparkUp.withdraw(1);
        vm.stopPrank();

        (, , , , , uint256 amountCollected, bool completed) = sparkUp.getIdea(1);

        uint256 expectedFee = (2 ether * 5) / 100; // 5% of 2 ether = 0.1 ether
        uint256 expectedToOwner = 2 ether - expectedFee; // 1.9 ether

        assertEq(
            user.balance,
            9.9 ether,
            "Owner should receive 95% of funds"
        );
        assertEq(
            address(sparkUp).balance,
            0.1 ether, // 5% fee remains
            "Contract should keep 5% fee"
        );
        assertEq(amountCollected, 0, "Amount collected should be zero after withdrawal");
        assertTrue(completed, "Idea should be marked completed");    
    }

    function test_refund() public {
        // Tests refunding a contributor before deadline
        // Verifies amountCollected decreases appropriately

        vm.startPrank(fundraiser);
        sparkUp.createIdea("Idea 1", "Description 1" , 2 ether, block.timestamp + 7 days);
        sparkUp.fundIdea{value: 1 ether}(1);
        sparkUp.refund(1, fundraiser);
        (string memory storedTitle, string memory storedDescription, address owner,
        uint256 fundGoal, uint256 storedDeadline, uint256 amountCollected, bool completed) = sparkUp.getIdea(1);
        assertEq(amountCollected, 0);
        vm.stopPrank();
    }


    function test_WithdrawFees() public {
        // Tests owner withdrawing 5% fee after main withdrawal
        // Verifies complete fee accounting workflow

        vm.startPrank(fundraiser);
        sparkUp.createIdea("Test", "Desc", 1 ether, block.timestamp + 1 days);
        sparkUp.fundIdea{value: 1 ether}(1);
        vm.stopPrank();

        assertEq(address(sparkUp).balance, 1 ether);

        vm.prank(fundraiser);
        sparkUp.withdraw(1);
        
        assertEq(address(sparkUp).balance, 0.05 ether);
        assertEq(fundraiser.balance, 9.95 ether);

        vm.prank(user);
        sparkUp.withdrawFees(1);

        assertEq(address(sparkUp).balance, 0);
        assertEq(user.balance, 0.05 ether);
    }
}