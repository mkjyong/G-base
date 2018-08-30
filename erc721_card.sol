pragma solidity ^0.4.19;


contract ERC721_card {
    event cardTransfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event cardApproval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function transfer(address _to, uint256 _tokenId) public;
    function approve(address _to, uint256 _tokenId) public;
    function takeOwnership(uint256 _tokenId) public;
}
