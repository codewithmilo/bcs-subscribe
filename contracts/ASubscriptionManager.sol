//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

// The SubscriptionManager interface

abstract contract ASubscriptionManager {

    event Subscribed(address subscriber, uint duration);
    event Renewed(address subscriber, uint duration);
    event Expired(address subscriber);
    event Paused(address subscriber);
    event Cancelled(address subscriber);

    // Sends subscription & duration token, creates subscription info
    function _subscribe(address subscriber, uint _duration) internal virtual;

    // Return true if an active subscription is expired
    // (false if sub is not active or has not expired)
    function checkExpiration(address subscriber) internal virtual view returns (bool);

    // Burns duration token only, sets status to expired
    function _expire(address subscriber) internal virtual;

    // This one is gonna be interesting. I think we want to only renew when the sub is inactive
    // Which means, there is no such thing as auto-renewal: Unfortunate maybe, but also ascribes
    // to the greater ideal of all power to user, where predatory "I forgot to cancel" renewal
    // charges go away
    function _renew(address subscriber, uint _duration) internal virtual;

    // Burns subscription & duration token, sets status to cancelled
    function _cancel(address subscriber) internal virtual;

    // Burns duration token only, sets status to paused
    function _pause(address subscriber) internal virtual;
}
