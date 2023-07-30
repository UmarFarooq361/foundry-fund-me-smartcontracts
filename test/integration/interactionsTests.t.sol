// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WidthdrawFundMe} from "../../script/Interaction.s.sol";

contract InteractionsTest is Test{
    address USER = makeAddr("user");
    uint256 constant SentValue = 0.1 ether;
    uint256 constant InitialAmount = 10 ether;
    FundMe fundMe;
    function setUp() external{
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, InitialAmount); // add some ether to our new created user for testing purpose
    }

    function testUsersCanFundAndOwnerWidthraw() public{
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WidthdrawFundMe widthdrawFundMe = new WidthdrawFundMe();
        widthdrawFundMe.widthdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);

    }
}