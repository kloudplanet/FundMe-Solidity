// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

// we're importing AggregatorV3Interface from chainlink to get latest eth / USD price.
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";


//this is how we can define custom error message
error NotOwner();

contract FundMe {

    // using PriceConverter library
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address public /* immutable */ i_owner;

    // here we're converting 50 USD to ETH so we can compare it easyly in getConversionRate method.
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
    
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {

        // msg.value.getConversionRate this is how we can call library function. 
        // it's looks like msg.value has getConversionRate as a method.
        // actually msg.value is first argument to getConversionRate method.
        require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    
    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    
    // modifier is the way to defind require statement once and can utilize in many places.
    // here we're chacking that if owner of this smart contract is calling the funtion or not.
    // if yes, then it will go ahead and call remaining code of actual function where we use the modifier
    // if not, then it will revert back the transcation with error message.
    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    
    function withdraw() payable onlyOwner public {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        // in solidity we can transfer balance using below 3 methods.
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()

    /* 
    facclback() and receive() are the special function.
    when we call smart contract without any data it will call receive() and with argumnt it will call fallback() (see above image.)
    any one can fund to this contract using any wallet for ex metamask without using fund method in that case
    we can't keep track of all the funders that's why we're calling fund() method in these special function
    so anyhow if this smart contract get funded it will be done only by fund method.
    */
    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly
