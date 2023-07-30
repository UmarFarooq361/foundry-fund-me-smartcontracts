// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script{
    uint256 constant SendValue = 0.1 ether;
    function fundFundMe(address mostRecentDeployedContract) public{
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployedContract)).fund{value: SendValue}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SendValue);
    }

    function run() external{
        address mostRecentDeployedContract = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        fundFundMe(mostRecentDeployedContract);
    }    
}

contract WidthdrawFundMe is Script{
    function widthdrawFundMe(address mostRecentDeployedContract) public{
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployedContract)).withdraw();
        vm.stopBroadcast();
        console.log("widthdraw FundMe ");
    }

    function run() external{
        address mostRecentDeployedContract = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        widthdrawFundMe(mostRecentDeployedContract);
    }    
}