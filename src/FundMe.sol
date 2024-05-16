// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
 
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from './PriceConverter.sol';
 
contract FundMe {
    using PriceConverter for uint256;
 
    address private immutable i_owner;
    //We must multiply by 10^18 because we manipulate 18decimals
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
 
    address[] private s_funders;
    mapping (address funders => uint256 amounFunded) private s_fundedAmountBy;
 
    AggregatorV3Interface private s_priceFeed;
 
    //Events
    event Funded(address funder, uint256 amount);
 
    constructor(address priceFeed) {
        i_owner = msg.sender;    
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }
 
    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) > MINIMUM_USD, "The minimum ammount to send is 5 USD");
        s_fundedAmountBy[msg.sender] = s_fundedAmountBy[msg.sender] + msg.value;
        s_funders.push(msg.sender);
        //Emit Event
        emit Funded(msg.sender, msg.value);
    }
 
 
    modifier minimumAmount {
        require(msg.value > 1e18, "The minimum ammount to send is 1 ETH");
        _;
    }
 
    modifier onlyOwner() {
        require(msg.sender == i_owner, 'You are not the owner !');
        _;
    }
 
    function withdrawal() public onlyOwner {
        //Empty the mapping 'fundedAmountBy'
        for (uint256 i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_fundedAmountBy[funder] = 0;
        }
        s_funders = new address[](0);
 
        //As it returns nothing, we can write
        (bool successCall, ) = payable(msg.sender).call{value: address(this).balance}("");    
        require(successCall, "Call to send ETH failed");
 
    }
 
    function getVersion() public view returns (uint256){
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return s_priceFeed.version();
    }
 
    receive() external payable {
        fund();
    }
 
    fallback() external payable {
        fund();
    }
 
    function getAmountFundedByAddress(address addr) external view  returns(uint256) {
        return s_fundedAmountBy[addr];
    }
 
    function getFunders(uint256 index) external view returns(address) {
        return s_funders[index];
    }
 
    function getOwner() external view returns(address) {
        return i_owner;
    }
}