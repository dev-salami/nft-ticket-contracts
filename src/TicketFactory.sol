// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TicketNFT.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract TicketFactory {
    TicketNFT[] public Tickets;

    address public immutable implementation;

    constructor(address contractAddr) {
        //   implementation = address(new TicketNFT());
        implementation = address(contractAddr);
    }

    event TicketCreated(address _counterAddress);

    function deployTicket(
        address _owner,
        string memory _ticketName,
        string memory _ticketCode,
        uint256 _maxTicket,
        uint256 _publicTicketPrice,
        uint256 _vipTicketPrice
    ) public {
        address clone = (Clones.clone(implementation));
        TicketNFT ticket = TicketNFT(clone);
        ticket.initialize(_owner, _ticketName, _ticketCode, _maxTicket, _publicTicketPrice, _vipTicketPrice);

        Tickets.push(ticket);
        emit TicketCreated(address(ticket));
    }
    // function createClone(address _owner, string memory _name, string memory _symbol) public returns (address) {
    //     address clone = Clones.createClone(implementation);
    //     // Pass constructor arguments to the clone through encoded calldata
    //     bytes memory initCalldata = abi.encodeWithSelector(TicketNFT.constructor.selector, _name, _symbol);
    //     (bool success, ) = clone.call(initCalldata);
    //     require(success, "Initialization failed");
    //     proxyAdmin.transferOwnership(clone, _owner); // Transfer ownership to the caller
    //     return clone;
    // }
}
