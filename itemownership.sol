pragma solidity ^0.4.19;


import "./erc721_item.sol";
import "./safemath.sol";
import "./itemfactory.sol";

contract ItemOwnership is ERC721_item, itemFactory {

    using SafeMath for uint256;

    mapping (uint => address) itemApprovals;

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return ownerToItem[_owner].length;
    }

    function transfer(address _to, uint128 _tokenId) public onlyOwnerOf(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _to, uint128 _tokenId) public onlyOwnerOf(_tokenId) {
        itemApprovals[_tokenId] = _to;
        emit itemApproval(msg.sender, _to, _tokenId);
    }

    function takeOwnership(uint128 _tokenId) public {
        require(itemApprovals[_tokenId] == msg.sender, "You can't do it");
        address owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender, _tokenId);
    }

    function _transfer(address _from, address _to, uint128 _tokenId) private {
        ownerToItem[_to].length++;
        ownerToItem[_from].length--;
        item memory temp = swift(_tokenId, _from);
        ownerToItem[_to].push(temp);
        emit itemTransfer(_from, _to, _tokenId);
    }
}