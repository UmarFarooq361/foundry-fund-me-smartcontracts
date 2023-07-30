// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    address USER = makeAddr("user");
    uint256 constant SentValue = 0.1 ether;
    uint256 constant InitialAmount = 10 ether;
    FundMe fundMe;
    function setUp() external{
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, InitialAmount); // add some ether to our new created user for testing purpose
    }
    function testMinimunPrice() public{
        assertEq(fundMe.MINIMUM_USD(),5e18);
    }
    function testOwner()public{
        // assertEq(address(this), fundMe.i_owner());
        assertEq(msg.sender, fundMe.i_owner());
    }
    function testVersion() public{
        assertEq(fundMe.getVersion(),4);
    }
    // fund testing
    function testMinimunFunding() public {
        vm.expectRevert(); //now in next line its expecting reverts
        fundMe.fund();
    }
    function testFundAmountUpdates() public{
        vm.prank(USER); // tx sended by this prank user
        fundMe.fund{value: SentValue}();
        uint256  amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(SentValue, amountFunded);
    }
    function testFunderAddedToFundersArray() external{
        vm.prank(USER); // tx sended by this prank user
        fundMe.fund{value: SentValue}();
        address funder = fundMe.getFunders(0);
        assertEq(USER, funder);
    }

    //widthdraw testing
    modifier funded(){
        vm.prank(USER); // tx sended by this prank user
        fundMe.fund{value: SentValue}();
        _;
    }
    function testOnlyOwnerCanWithdraw() external funded{
        

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
        
    }
    function testWithdrawWithSingleFunder() external funded{
        // arrange for test
        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;

        // act for test
        vm.prank(fundMe.i_owner());
        fundMe.withdraw();

        //revert for test
        uint256 endingOwnerBalance = fundMe.i_owner().balance;
        uint256 endingFunderBalance = address(fundMe).balance;
        assertEq(endingFunderBalance, 0);
        assertEq(startingOwnerBalance + startingFunderBalance, endingOwnerBalance);
        
    }

    function testWithdrawWithMultipleFunder() external funded{
        // arrange for test
        uint160 StartingIndex = 1;
        uint160 NumberOfFunders = 10;

        for (uint160 i = StartingIndex; i <= NumberOfFunders; i++){
            //hoax in foundry is in forge std which do both prank and deal
            hoax(address(i), SentValue);
            fundMe.fund{value: SentValue}();
        }

        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;

        // act for test
        vm.startPrank(fundMe.i_owner());
        fundMe.withdraw();
        vm.stopPrank();

        //revert for test
        uint256 endingOwnerBalance = fundMe.i_owner().balance;
        uint256 endingFunderBalance = address(fundMe).balance;
        assertEq(endingFunderBalance, 0);
        assertEq(startingOwnerBalance + startingFunderBalance, endingOwnerBalance);

    }
    function testAfterWithdrawDataStructureReset() external funded{
        vm.prank(fundMe.i_owner());
        fundMe.withdraw();

        uint256 lenthOfFundersArray = fundMe.getLengthOfFunders();
        uint256 balanceOfFunderMapping = fundMe.s_addressToAmountFunded(fundMe.i_owner());
        assertEq(lenthOfFundersArray, 0);
        assertEq(balanceOfFunderMapping, 0);
    }
}