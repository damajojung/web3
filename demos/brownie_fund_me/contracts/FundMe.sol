// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol"; // Check out the function at github:
// https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.4/interfaces/AggregatorV3Interface.sol
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    // This contract should accept payments
    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded; // mapping that shows which address funded how much money
    address[] public funders; // keep track of all the funders
    address public owner;

    constructor() public {
        owner = msg.sender; //the sender is gonna be us - its the person who is going to deploy the contract
    }

    function fund() public payable {
        // We need a function that accept funds - payable == this func can be used to pay for things
        // 1 Dollar
        uint256 minimumUSD = 1 * 10**18; //we define the minimum value
        // now we want to make sure that the sent value is at least 50$
        // We could use an if-statement here, but require() is better
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend more ETH."
        ); //If the sended ETH amount is less then 50, we stop the execution and revert the amount
        // revert = send back the money

        // lets keep track of all the addresses that sent us money
        // add money from the address to the smart contract
        addressToAmountFunded[msg.sender] += msg.value;

        // msg.sender = address of the functioncall
        // msg.value = how much they sent

        ////////
        // We want to use USD - How to convert ETH to USD?

        funders.push(msg.sender); // store the funder in the funder array
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        );
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        // Get ETH price in USD
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        );
        (, int256 answer, , , ) = priceFeed.latestRoundData(); // latestRoundData = tuple with 5 entries, but we need only price. We leave the commas of the other data sources
        return uint256(answer * 10000000000);
    }

    // 1 GWEI = 1000000000 WEI
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUSD;
    }

    // modifiers are used to change the behaviour of a function in a declarative way
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner of this contract!"); // Do this require statement first and then...
        _; //execute the code wherever the modifier is.
    }

    function withdraw() public payable onlyOwner {
        // we only want that the owner of the contract is able to withdraw money, this can be ensured the following way
        // msg.sender == owner
        // For this, we need an owner --> should be initiated in the constructor which is executed right after the deployment of the contract
        msg.sender.transfer(address(this).balance); // We send all the eth that has be sent to our address
        // this is a solidity keyword = the contract we are currently in
        // address(this) = the address of the contract we are currently in
        // address(this).balance = ETH balance of the current smart contract

        // we are the only ones who can withdraw from the application
        // when we withdraw, we reset all the funders who have contributed in our crowdsourcing application
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            // start at 0, stop at end of array, add 1 to index at end of loop
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        //reset the funders array
        funders = new address[](0);
    }
}
