pragma solidity ^0.4.19;


import "./cardfactory.sol";
import "./erc721.sol";
import "./safemath.sol";


contract CardOwnership is CardFactory, ERC721 {

    using SafeMath for uint256;

    mapping (uint => address) cardApprovals;

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return ownerCardCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return cardToOwner[_tokenId];
    }

    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        cardApprovals[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function takeOwnership(uint256 _tokenId) public {
        require(cardApprovals[_tokenId] == msg.sender, "You can't do it");
        address owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender, _tokenId);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownerCardCount[_to] = ownerCardCount[_to].add(1);
        ownerCardCount[msg.sender] = ownerCardCount[msg.sender].sub(1);
        cardToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

   
}
