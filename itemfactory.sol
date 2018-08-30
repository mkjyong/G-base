pragma solidity ^0.4.19;
pragma experimental ABIEncoderV2;

import "./ownable.sol";
import "./safemath.sol";
import "./goldownership.sol";


contract itemFactory is goldOwnership {

    using SafeMath for uint256;

    event NewItem(uint name, uint dna); // 로컬에 저장
    event starting();

    address gameOwner;
    uint128 dnaDigits = 16;
    uint128 dnaModulus = uint128(10) ** dnaDigits;

    struct item {
        uint128 name;//이름 충분히 가능
        uint128 dna;//아이템 속성 충분히 분류가능
        bool equiped;
    }
  
    mapping (address => item[]) public ownerToItem;

    constructor(address _gameOwner) public {
        gameOwner = _gameOwner;
    }

    modifier onlyOwner() {
        require(msg.sender == gameOwner, "You can't do it");
        _;
    }

    //return index of item
    function _itemOwnerOf(uint128 _item) internal returns (uint) {
        item[] memory temp = ownerToItem[msg.sender];
        bool isRight = false;
        uint index;
        for(uint i = 0 ; i < temp.length ; i++){
            if(temp[i].name == _item){
                isRight = true;
                index = i;
            }
        }
        require(isRight);
        return i;
    }

    function createRandomItem(uint128 _name) public {
        require(balanceOf(msg.sender) >= 2500, "Earn more money!!");

        uint128 randDna = _generateRandomDna();
        randDna = randDna - randDna % 100;
        _createItem(_name, randDna);
    }

    function _createItem(uint128 _name, uint128 _dna) internal {
        ownerToItem[msg.sender].push(item(_name, _dna, false));
        subGold(msg.sender,2500);
        emit NewItem(_name, _dna);
    }

    function _generateRandomDna() private view returns (uint128) {
        uint128 rand = uint128(now % 100);
        return rand % dnaModulus;
    }

    //자신의 아이템은 로컬에 저장되있어서 이 함수 사용할 필요 없음.
    function getItemssByOwner(address _owner) external view returns(item[]) {
        return ownerToItem[_owner];
    }

    function getGoldByOwner(address _owner) external view returns(uint) {
        return balanceOf(msg.sender);
    }

    function swift_Delete(uint128 _itemId, address _owner) public returns(item) {
        uint _index = _itemOwnerOf(_itemId);
        item storage myItem = ownerToItem[msg.sender][_index];
        delete ownerToItem[msg.sender][_index];
        for(uint k = _index; k < ownerToItem[msg.sender].length - 1 ; k++) {
            ownerToItem[msg.sender][k] = ownerToItem[msg.sender][k+1];
        }
        ownerToItem[msg.sender].length--;
        return myItem;
    }

    function Fusion(uint128 _itemId, uint16 _targetId) public {
        item memory myItem = swift_Delete(_itemId, msg.sender); 
        item memory targetItem = swift_Delete(_targetId, msg.sender);

        uint128 targetDna = targetItem.dna;
        targetDna = targetDna % dnaModulus;
        uint128 newDna = (myItem.dna + targetDna) / 2;
        _createItem(myItem.name, newDna);
    }

    function equiping(uint128 _itemId) external {
        uint index = _itemOwnerOf(_itemId);
        ownerToItem[msg.sender][index].equiped = true;
    }

    function unEquiping(uint128 _itemId) external {
        uint index = _itemOwnerOf(_itemId);
        ownerToItem[msg.sender][index].equiped = false;
    }
}