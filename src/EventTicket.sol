// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/**
 * @title EventTicket
 * @dev ERC721 token representing event tickets with additional features.
 */
contract EventTicket is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Pausable, Ownable, ERC721Burnable {
    uint256 private _nextTokenId;
    uint256 public immutable i_maxTicket;
    uint256 public publicTicketPrice;
    uint256 public vipTicketPrice;

    mapping(address => bool) public vipList;

    /**
     * @dev Constructor to initialize the EventTicket contract.
     * @param _eventName The name of the event.
     * @param _eventCode A code representing the event.
     * @param _maxTicket The maximum number of tickets available for the event.
     */
    constructor(
        string memory _eventName,
        string memory _eventCode,
        uint256 _maxTicket,
        uint256 _publicTicketPrice,
        uint256 _vipTicketPrice
    ) ERC721(_eventName, _eventCode) Ownable(tx.origin) {
        i_maxTicket = _maxTicket;
        publicTicketPrice = _publicTicketPrice;
        vipTicketPrice = _vipTicketPrice;
    }

    /**
     * @dev Fallback function to receive Ether.
     */
    receive() external payable {}

    /**
     * @dev Internal function to define the base URI for metadata.
     */
    // function _baseURI() internal pure override returns (string memory) {
    //     return "https://ipfs.io/ipfs/QmYnKxc12n3KVJWK3j3XxV6oDbFy6eHC2ezt1gDAAzFoYj/";
    // }

    /**
     * @dev Pauses the contract. Only callable by the owner.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses the contract. Only callable by the owner.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev Allows the purchase of a public ticket.
     * @param _uri URI for the ticket metadata.
     * @param _buyer Address of the ticket buyer.
     */
    function buyPublic_Ticket(string memory _uri, address _buyer) external payable {
        require(msg.value == publicTicketPrice, "Incorrect amount sent");

        _buyTicket(_uri, _buyer);
    }

    /**
     * @dev Allows the purchase of a VIP ticket.
     * @param _uri URI for the ticket metadata.
     * @param _buyer Address of the ticket buyer.
     */
    function buyVIP_Ticket(string memory _uri, address _buyer) external payable {
        require(vipList[msg.sender], "You are not on the VIP list");
        require(msg.value == vipTicketPrice, "Incorrect amount sent");
        _buyTicket(_uri, _buyer);
    }

    /**
     * @dev Internal function to handle the purchase of a ticket.
     * @param _uri URI for the ticket metadata.
     * @param _buyer Address of the ticket buyer.
     */
    function _buyTicket(string memory _uri, address _buyer) internal {
        require(totalSupply() < i_maxTicket, "Ticket for event sold out");
        uint256 tokenId = _nextTokenId++;
        _safeMint(_buyer, tokenId);
        _setTokenURI(tokenId, _uri);
    }

    /**
     * @dev Checks if a given ticket is valid for the specified owner and token ID.
     * @param owner Address of the ticket owner.
     * @param tokenId Token ID of the ticket.
     * @return Whether the ticket is valid for the given owner and token ID.
     */
    function isTicketValid(address owner, uint256 tokenId) external view returns (bool) {
        return ownerOf(tokenId) == owner;
    }

    /**
     * @dev Sets VIP status for a list of addresses. Only callable by the owner.
     * @param _addresses List of addresses to set as VIP.
     */
    function setVip(address[] calldata _addresses) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            vipList[_addresses[i]] = true;
        }
    }

    function vipEligibilty() external view returns (bool) {
        return vipList[msg.sender];
    }

    /**
     * @dev Withdraws the contract balance to the owner address. Only callable by the owner.
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool sent,) = payable(owner()).call{value: balance}("");
        require(sent, "Balance not sent");
    }

    /**
     * @dev Overrides the internal update function.
     * @param to Address to transfer to.
     * @param tokenId Token ID being transferred.
     * @param auth Authorized address.
     * @return The updated address.
     */
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    /**
     * @dev Overrides the internal increase balance function.
     * @param account Account to increase the balance for.
     * @param value Value to increase.
     */
    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    /**
     * @dev Overrides the public token URI function.
     * @param tokenId Token ID to get the URI for.
     * @return The token URI.
     */
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /**
     * @dev Allows the owner to delete the event and receive the remaining balance. Only callable by the owner.
     * @return Whether the deletion was successful.
     */
    function deleteEvent() public onlyOwner returns (bool) {
        selfdestruct(payable(owner()));
        return true;
    }

    /**
     * @dev Overrides the supportsInterface function.
     * @param interfaceId Interface ID to check.
     * @return Whether the interface is supported.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
