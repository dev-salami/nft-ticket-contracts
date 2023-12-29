// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";

contract TicketNFT is
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable,
    ERC721PausableUpgradeable,
    OwnableUpgradeable,
    ERC721BurnableUpgradeable
{
    uint256 private _nextTokenId;
    uint256 public i_maxTicket;
    uint256 public public_Ticket_Price;
    uint256 public vip_Ticket_Price;

    mapping(address => bool) public vipList;

    // constructor(
    //     address _owner,
    //     string memory _ticketName,
    //     string memory _ticketCode,
    //     // string memory _imageURI,
    //     uint256 _maxTicket
    // ) ERC721(_ticketName, _ticketCode) Ownable(_owner) {
    //     i_maxTicket = _maxTicket;
    // }

    function initialize(
        address _owner,
        string memory _ticketName,
        string memory _ticketCode,
        uint256 _maxTicket,
        uint256 _publicTicketPrice,
        uint256 _vipTicketPrice
    ) external initializer {
        __ERC721_init(_ticketName, _ticketCode);
        OwnableUpgradeable.__Ownable_init(_owner);
        ERC721PausableUpgradeable.__ERC721Pausable_init_unchained();
        ERC721BurnableUpgradeable.__ERC721Burnable_init_unchained();
        ERC721URIStorageUpgradeable.__ERC721URIStorage_init_unchained();
        ERC721EnumerableUpgradeable.__ERC721Enumerable_init_unchained();

        i_maxTicket = _maxTicket;
        public_Ticket_Price = _publicTicketPrice;
        vip_Ticket_Price = _vipTicketPrice;

        transferOwnership(_owner);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://sepolia.etherscan.io/assets/svg/logos/logo-etherscan.svg?v=0.0.5";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /// TICKET BUYING ///
    function buyPublic_Ticket(string memory _uri) public payable {
        require(msg.value == public_Ticket_Price, " Incorrect amount sent");

        _buyTicket(_uri);
    }

    function buyVIP_Ticket(string memory _uri) public payable {
        require(vipList[msg.sender], "You are not on the vip list");
        require(msg.value == vip_Ticket_Price, "Incorrect amount sent");
        _buyTicket(_uri);
    }

    function _buyTicket(string memory _uri) internal {
        require(totalSupply() < i_maxTicket, "Ticket for event sold out");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _uri);
    }

    function isValid(address owner, uint256 tokenId) external view returns (bool) {
        if (ownerOf(tokenId) == owner) {
            return true;
        } else {
            return false;
        }
    }

    /// Ticket Settings
    function setVip(address[] calldata _addresses) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            vipList[_addresses[i]] = true;
        }
    }

    function withdraw(address _addr) external onlyOwner {
        // get the balance of the contract
        uint256 balalnce = address(this).balance;
        (bool sent,) = payable(_addr).call{value: balalnce}("");
        require(sent, "Balance not sent");
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721PausableUpgradeable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721URIStorageUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
