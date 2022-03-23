//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./SubscriptionInfo.sol";
import "./SubscriptionManager.sol";
import "./SubscriptionMessager.sol";

contract Subscription is SubscriptionInfo, SubscriptionManager, SubscriptionMessager {

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

    function getSubInfo(address subscriber) public view returns (SubInfo memory) {
        return getSub(subscriber);
    }

    function getAllSubscribers() public view returns (address[] memory) {
        return getSubscribers();
    }

    function message() public returns (uint) {
        uint msgId = createMessage();
        sendMessages(msgId);
        return msgId;
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
    function getUpToDateStatus(address subscriber) public returns (SubStatus) {
        // first check if it's expired, update if so
        bool isExpired = checkExpiration(subscriber);
        if (isExpired) _expire(subscriber);

        // after _expire, this will be up to date
        return getSubStatus(subscriber);
    }

    function cancel(address subscriber) public { _cancel(subscriber); }
    function pause(address subscriber) public { _pause(subscriber); }
}
