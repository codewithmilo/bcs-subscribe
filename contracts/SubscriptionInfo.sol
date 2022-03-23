//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

// Base contract for the storage and access of subscriptions

contract SubscriptionInfo {

    // The store of subscribers: address => subscription info
    mapping (address => SubInfo) private subscriptions;

    // List of active subscribers
    address[] private subscribers;


    // Subscription Information:
    // Status of the subscription
    // Expiration of the subscription token; the global time past which it is expired
    // Duration of the subscription; which duration token applies for renewal
    struct SubInfo {
        uint expiration;
        uint duration;
        SubStatus status;
    }

    enum SubStatus { Active, Paused, Cancelled, Expired }


    // TOKEN TYPES:
    // SUBSCRIPTION is the "NFT" that acts as an account
    // DURATION_XXX represents the duration of the subscription before it expires (and is burned, requiring re-purchasing)
    // MESSAGE is the token sent as any given message; the attached metadata will have the URL of the message contents

    uint internal constant SUBSCRIPTION = 0;

    uint internal constant DURATION_FREE = 1;
    uint internal constant DURATION_LIFE = 2; // must be separate from "free" to denote it must be paid for
    uint internal constant DURATION_WEEK = 3;
    uint internal constant DURATION_MONTH = 4;
    uint internal constant DURATION_YEAR = 5;
    // These just seem less likely to be used
    uint internal constant DURATION_TWO_MONTH = 6;
    uint internal constant DURATION_HALF_YEAR = 7;
    uint internal constant DURATION_QUARTER = 8;

    uint internal constant MESSAGE = 9;

    // The amount of time in seconds for each subscription length
    mapping (uint => uint) internal durations;

    function initDurations() internal {
        // build the durations mapping
        durations[DURATION_FREE] = 0;
        durations[DURATION_LIFE] = 0;
        durations[DURATION_WEEK] = 604800;
        durations[DURATION_MONTH] = 604800 * 4;
        durations[DURATION_YEAR] = 604800 * 52;
        durations[DURATION_TWO_MONTH] = 604800 * 8;
        durations[DURATION_HALF_YEAR] = 604800 * 26;
        durations[DURATION_QUARTER] = 604800 * 13;

    }

    function getSubscribersCount() internal view returns (uint) { return subscribers.length; }
    function getSubscribers() internal view returns (address[] storage) { return subscribers; }

    function getSubDuration(address subscriber) internal view returns (uint) { return subscriptions[subscriber].duration; }
    function getSubExpiration(address subscriber) internal view returns (uint) { return subscriptions[subscriber].expiration; }
    function getSubStatus(address subscriber) internal view returns (SubStatus) { return subscriptions[subscriber].status; }
    function getSub(address subscriber) internal view returns (SubInfo storage) { return subscriptions[subscriber]; }

    function addSubscriber(address subscriber, SubInfo memory info) internal returns (address) {
        subscriptions[subscriber] = info;
        subscribers.push(subscriber);
        return subscriber;
    }

    function setSubDuration(address subscriber, uint _duration) internal returns (uint) {
        subscriptions[subscriber].duration = _duration;
        return _duration;
    }

    function setSubExpiration(address subscriber, uint _expiration) internal returns (uint) {
        subscriptions[subscriber].expiration = _expiration;
        return _expiration;
    }

    function setSubStatus(address subscriber, SubStatus _status) internal returns (SubStatus) {
        subscriptions[subscriber].status = _status;
        return _status;
    }

    function removeSubscriber(address subscriber) internal {
        delete subscriptions[subscriber];

        uint index;
        for (uint i = 0; i < subscribers.length; i++) {
            if (subscribers[i] == subscriber) {
                index = i;
                break;
            }
        }
        
        delete subscribers[index];
    }
}
