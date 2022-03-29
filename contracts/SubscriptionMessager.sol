//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./SubscriptionInfo.sol";

// The contract for sending messages to subscription holders
// This works by minting a new token, which represents the message 
//
// Overall, this is probably not a good idea, thus isn't included in
// the main Subscription contract

abstract contract SubscriptionMessager is ERC1155, SubscriptionInfo {
    using Counters for Counters.Counter;

    Counters.Counter private _messageIds;

    function createMessage() internal returns (uint) {

        // find how many subscribers there are
        uint count = getSubscribersCount();

        // Mint new tokens, each of which represents a message
        _messageIds.increment();
        uint newMsgId = _messageIds.current();

        _mint(address(this), newMsgId, count, "");

        return newMsgId;
    }

    function sendMessages(uint msgId) internal {
        // get the list of active subscribers
        address[] storage subscribers = getSubscribers();

        // send the message token to them all
        for (uint i = 0; i < subscribers.length; i++) {
            // this absolutely won't work!!
            safeTransferFrom(address(this), subscribers[i], msgId, 1, "");
            emit TransferSingle(address(this), address(this), subscribers[i], msgId, 1);
        }
    }
}
