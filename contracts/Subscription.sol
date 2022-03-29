//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./SubscriptionInfo.sol";
import "./SubscriptionManager.sol";

contract Subscription is SubscriptionInfo, SubscriptionManager {

    // cost of each subscription length
    mapping (uint => uint) public prices;

    constructor(uint[] memory _prices) payable ERC1155("") {
        initPrices(_prices);
        initDurations();
    }

    function initPrices(uint[] memory _prices) private {
        // set the prices for each duration
        prices[DURATION_LIFE] = _prices[0];
        prices[DURATION_WEEK] =_prices[1];
        prices[DURATION_MONTH] =_prices[2];
        prices[DURATION_YEAR] =_prices[3];
        prices[DURATION_TWO_MONTH] =_prices[4];
        prices[DURATION_HALF_YEAR] =_prices[5];
        prices[DURATION_QUARTER] =_prices[6];
    }

    // update the price for a given duration
    function updatePrice(uint duration, uint price) public onlyOwner {
        prices[duration] = price;
    }

    function getSubInfo(address subscriber) public view onlyOwner returns (SubInfo memory) {
        return getSub(subscriber);
    }

    function getAllSubscribers() public view onlyOwner returns (address[] memory) {
        return getSubscribers();
    }

    function subscribe(uint duration) public payable {

        // check the price (if it's not free)
        if (duration != DURATION_FREE) { 
            uint cost = prices[duration];
            require(msg.value >= cost, "Insufficient funds");
        }

        // subscribe!
        _subscribe(msg.sender, duration);
    }

    function renew(uint duration) public payable {

        // check the price (if it's not free)
        if (duration != DURATION_FREE) {
            uint cost = prices[duration];
            require(msg.value >= cost, "Insufficient funds");
        }

        // renew!
        _renew(msg.sender, duration);
    }

    // Get the current status, (potentially does an UPDATE)
    function getUpToDateStatus(address subscriber) private returns (SubStatus) {
        // first check if it's expired, update if so
        bool isExpired = checkExpiration(subscriber);
        if (isExpired) _expire(subscriber);

        // after _expire, this will be up to date
        return getSubStatus(subscriber);
    }

    // Check if the user is subscribed to the service
    function isSubscribed(address user) public returns (bool) {
        return getUpToDateStatus(user) == SubStatus.Active;
    }

    function cancel(address subscriber) public { _cancel(subscriber); }
    function pause(address subscriber) public { _pause(subscriber); }
}
