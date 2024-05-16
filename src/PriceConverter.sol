// SPDX-License-Identifier: MIT
 
pragma solidity ^0.8.18;
 
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
 
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256){
        (, int256 answer, , , ) = priceFeed.latestRoundData();    
        //We must multiply by 1e10 because the "priceFeed.latestRoundData()" returns a number with 8 decimals
        // and we must manipulate 18 decimals
        return uint256(answer * 1e10);
    }
 
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        //ethPrice is with 18 decimals
        //ethAmount is with 18 decimals
        // So we divide by 10^18 to get a number with 18 decimals
        uint256 ethAmountInUsd =  (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
 
}