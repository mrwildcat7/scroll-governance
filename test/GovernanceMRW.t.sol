// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SimpleVotingToken} from "../src/GovernanceMRW.sol";

contract GovernanceTokenTest is Test {
    SimpleVotingToken public token;
    address delegate = address(0x123);

    function setUp() public {
        vm.prank(delegate);
        token = new SimpleVotingToken();
    }

    function testMintedSupply() public {
        assertEq(token.totalSupply(), 21_000_000 ether);
        assertEq(token.balanceOf(delegate), 21_000_000 ether); // delegate owns all tokens
        assertEq(token.balanceOf(address(this)), 0); // test contract owns none
    }

    function testProposeAndVote() public {
        // Propose a new proposal
        vm.prank(delegate);
        token.propose("# Test Proposal. 1. Cats should rule the world.", block.timestamp + 1000);

        // Vote for the proposal
        vm.prank(delegate);
        token.castVote(1, true);

        // Check votes
        (string memory name, uint deadline, uint forVotes, uint againstVotes) = token.proposals(1);
        assertEq(name, "# Test Proposal. 1. Cats should rule the world.");
        assertEq(forVotes, 21_000_000 ether); // No tokens owned by this contract
        assertEq(againstVotes, 0);
    }
    function test_RevertWhenVoteWithoutTokens() public {
        // Propose a new proposal
        vm.prank(delegate);
        token.propose("# Test Proposal. 2. Dogs should rule the world.", block.timestamp + 1000);

        // Attempt to vote from an address with no tokens
        vm.expectRevert(); // Expect revert due to zero balance
        token.castVote(2, true);
    }

    function testCannotVoteTwice() public {
        vm.prank(delegate);
        token.propose("Double Vote Test", block.timestamp + 1000);

        vm.prank(delegate);
        token.castVote(1, true);

        // Try to vote again before deadline
        vm.prank(delegate);
        vm.expectRevert("Can't vote twice");
        token.castVote(1, true);
    }

    function testCannotVoteAfterDeadline() public {
        vm.prank(delegate);
        token.propose("Late Vote Test", block.timestamp + 1);

        // Move time forward past deadline
        vm.warp(block.timestamp + 2);

        vm.prank(delegate);
        vm.expectRevert("Voting period is over");
        token.castVote(1, true);
    }

    function test_RevertWhenTransferAfterVoting() public {
        vm.prank(delegate);
        token.propose("Transfer Block Test", block.timestamp + 1000);

        vm.prank(delegate);
        token.castVote(1, true);

        // Attempt to transfer tokens after voting, should revert due to blocked mapping
        vm.prank(delegate);
        vm.expectRevert("Tokens are blocked");
        token.transfer(address(0x456), 1 ether);
    }
}
