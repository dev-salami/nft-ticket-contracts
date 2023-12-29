// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {EventTicket} from "./EventTicket.sol";

contract EventManager {
    struct Event {
        address contractAddress;
        string eventName;
        string ticketImg;
    }

    Event[] private Events;
    mapping(address => Event[]) private userEvents;

    function createEvent(
        string memory _eventName,
        string memory _eventCode,
        string memory _eventImg,
        uint256 _maxTicket,
        uint256 _publicTicketPrice,
        uint256 _vipTicketPrice
    ) external {
        EventTicket eventTicket = new EventTicket(
            _eventName,
            _eventCode,
            _maxTicket,
            _publicTicketPrice,
            _vipTicketPrice
        );
        Event memory eventDetails = Event(address(eventTicket), _eventName, _eventImg);

        Events.push(eventDetails);
        userEvents[msg.sender].push(eventDetails);
    }

    function getEvents() external view returns (Event[] memory) {
        return Events;
    }

    function getUserEvent() external view returns (Event[] memory) {
        return userEvents[msg.sender];
    }

    function deleteEvent(uint256 _index) external {
        Events[_index] = Events[Events.length - 1];
        Events.pop();
    }
}
