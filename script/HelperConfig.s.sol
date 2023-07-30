// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/mockV3Aggregator.sol";

contract HelperConfig is Script{
    NetworkConfig public activePriceFeed;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;
    struct NetworkConfig{
        address priceFeed;
    }
        constructor(){
            if(block.chainid == 11155111){
            activePriceFeed = getSepoliaPriceFeed();
        }
        else{
            activePriceFeed = getAnvilPriceFeed();
        }
        }
        function getSepoliaPriceFeed() public pure returns(NetworkConfig memory){
            NetworkConfig memory networkConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
            return networkConfig;
        }
        function getAnvilPriceFeed() public returns(NetworkConfig memory){
            if(activePriceFeed.priceFeed != address(0)){
                return activePriceFeed;
            }
            vm.startBroadcast();
            MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
            vm.stopBroadcast();
            NetworkConfig memory networkConfig = NetworkConfig({priceFeed: address(mockV3Aggregator)});
            return networkConfig;
            

        }
    }

