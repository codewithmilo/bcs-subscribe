//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./SubscriptionInfo.sol";
import "./ASubscriptionManager.sol";

// The contract for managing a subscription: minting, sending, and burning 
// subscription & duration tokens.
// - Implements SubscriptionInfo, which defines the token types

abstract contract SubscriptionManager is ERC1155, SubscriptionInfo, ASubscriptionManager, Ownable {

    function _subscribe(address subscriber, uint duration) internal override {
        // make sure they don't have a subscription token already
        require(balanceOf(subscriber, SUBSCRIPTION) == 0, "Already subscribed");

        // get the expiration
        uint expiry = block.timestamp + durations[duration];

        // build the arrays here because they have to be dynamic...
        uint[] memory tokens = new uint[](2);
        tokens[0] = SUBSCRIPTION;
        tokens[1] = duration;
        uint[] memory amounts = new uint[](2);
        amounts[0] = 1;
        amounts[1] = 1;

        // subscribe!
        _mintBatch(subscriber, tokens, amounts, "");

        // set the subscription info
        SubInfo memory info;
        info.duration = duration;
        info.expiration = expiry;
        info.status = SubStatus.Active;

        addSubscriber(subscriber, info);

        emit Subscribed(subscriber, duration);
    }

    function checkExpiration(address subscriber) internal view override returns (bool) {
        SubInfo storage info = getSub(subscriber);

        // only check if it is active (otherwise who cares)
        if (info.status != SubStatus.Active) return false;

        return block.timestamp > info.expiration;
    }

    function _expire(address subscriber) internal override {
        // update the info
        setSubExpiration(subscriber, 0);
        setSubStatus(subscriber, SubStatus.Expired);

        // get the duration token id
        uint duration = getSubDuration(subscriber);

        // burn the duration token
        if (checkDuration(subscriber, duration, "PAUSE")) {
            _burn(subscriber, duration, 1);
            require(balanceOf(subscriber, duration) == 0, "Failed to burn duration token");
        }

        emit Expired(subscriber);
    }

    function _renew(address subscriber, uint duration) internal override {
        require(balanceOf(subscriber, SUBSCRIPTION) > 0, "Missing subscription");
        require(duration != DURATION_FREE, "No renewal for free subscription");

        // get the subscription
        SubInfo storage info = getSub(subscriber);

        require(info.duration != DURATION_FREE, "No renewal required for free subscriptions");
        require(info.duration != DURATION_LIFE, "No renewal required for lifetime subscriptions");

        require(info.status != SubStatus.Active, "Subscription is currently active");

        // get the expiry
        uint expiry = block.timestamp + durations[duration];

        // set the subscription info
        setSubDuration(subscriber, duration);
        setSubExpiration(subscriber, expiry);
        setSubStatus(subscriber, SubStatus.Active);

        emit Renewed(subscriber, duration);
    }

    function _cancel(address subscriber) internal override {
        require(balanceOf(subscriber, SUBSCRIPTION) > 0, "Missing subscription");
        require(msg.sender == owner() || msg.sender == subscriber, "Not allowed");

        // set their status as cancelled
        setSubStatus(subscriber, SubStatus.Cancelled);

        // figure out which duration token they have
        uint duration = getSubDuration(subscriber);

        // burn their tokens
        uint[] memory tokens;
        uint[] memory amounts;
        if (checkDuration(subscriber, duration, "CANCEL")) {
            tokens = new uint[](2);
            tokens[0] = SUBSCRIPTION;
            tokens[1] = duration;
            amounts = new uint[](2);
            amounts[0] = 1;
            amounts[1] = 1;
        } else {
            tokens = new uint[](1);
            tokens[0] = SUBSCRIPTION;
            amounts = new uint[](1);
            amounts[0] = 1;
        }

        _burnBatch(subscriber, tokens, amounts);
        require(balanceOf(subscriber, SUBSCRIPTION) == 0, "Failed to burn subscription token");
        require(balanceOf(subscriber, duration) == 0, "Failed to burn duration token");

        emit Cancelled(subscriber);
    }

    function _pause(address subscriber) internal override {
        require(balanceOf(subscriber, SUBSCRIPTION) > 0, "Missing subscription");
        require(msg.sender == address(this) || msg.sender == subscriber, "Not allowed");

        // set their status as paused
        setSubStatus(subscriber, SubStatus.Paused);

        // figure out which duration token they have (just log an error if they don't have it for some reason)
        uint duration = getSubDuration(subscriber);

        // burn the duration token
        if (checkDuration(subscriber, duration, "PAUSE")) {
            _burn(subscriber, duration, 1);
            require(balanceOf(subscriber, duration) == 0, "Failed to burn duration token");
        }

        emit Paused(subscriber);
    }

    // Check that the duration we have for the subscriber is held as a duration token
    // by the subscriber's wallet. Otherwise burning it will fail!
    function checkDuration(address subscriber, uint duration, string memory caller) private view returns (bool) {
        bool hasToken = balanceOf(subscriber, duration) > 0;
        if (!hasToken) {
            console.log("%s: subscriber expected to have %s duration token", caller, duration);
        }
        return hasToken;
    }
}
