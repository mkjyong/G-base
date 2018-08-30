pragma solidity ^0.4.19;


import "./ownable.sol";
import "./safemath.sol";

//각 캐릭터들의 능력, 체력 등은 아이템에서 받아오고 종합하여 게임 내에서 반영한다. job에 따라서 게임내 체력, 마력 분배표 저장
contract CardFactory is Ownable {

    using SafeMath for uint256;
    using SafeMath for uint32;

    event NewCard(uint cardId, string name, uint128 dna); // 로컬에 저장
    event Dead(uint cardId);

    /// name, dna, job바꾸기 기능(유료)
    struct Card {
        string name;
        uint128 dna;//캐릭터 디자인 가능 - 생김새 다 삽입 32개의 특징 삽입 가능  
                    //눈, 코, 입, 머리, 피부, 성별 등등 설계 나름
        uint8 job; //직업 세분화 가능
        uint32 level;
        uint40 exp; ///exp는 상세하게 체크하지 않는다. 게임내에서 체크하다가 게임 종료시에만 반영한다.
        bool dead;
    }

    Card[] public cards;

    mapping (uint => address) public cardToOwner;
    mapping (address => uint) ownerCardCount;

    ///모두 수정기능 있음
    uint creationFee = 0.3 ether;
    uint changeFee = 0.1 ether;

    modifier onlyOwnerOf(uint _cardId) {
        require(msg.sender == cardToOwner[_cardId]);
        _;
    }

    modifier aboveLevel(uint _level, uint _cardId) {
        require(cards[_cardId].level >= _level);
        _;
    }

    modifier isDead(uint _cardId) {
        require(!cards[_cardId].dead, "You are dead character");
        _;
    }

    /// 처음은 무료 그 다음부턴 과금
    function createCard(string _name, uint8 _job, uint128 _dna) public payable {
        if(ownerCardCount[msg.sender] == 0){
            _createCard(_name, _dna, _job);
        } else{
            require(msg.value == creationFee, "Not enough Ether");
            _createCard(_name, _dna, _job);
        }
    }

    function _createCard(string _name, uint128 _dna, uint8 _job) internal {
        uint id = cards.push(Card(_name, _dna, _job, 1, 0, false)) - 1;
        cardToOwner[id] = msg.sender;
        ownerCardCount[msg.sender]++;
        emit NewCard(id, _name, _dna);
    }

    function getCardsByOwner(address _owner) external view returns(uint[]) {
        uint[] memory result = new uint[](ownerCardCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < cards.length; i++) {
            if (cardToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
    
    function changeName(uint _cardId, string _newName) external payable onlyOwnerOf(_cardId) isDead(_cardId) {
        require(msg.value == changeFee);
        cards[_cardId].name = _newName;
        owner.transfer(msg.value);///
    }

    function changeDna(uint _cardId, uint16 _newDna) external payable onlyOwnerOf(_cardId) isDead(_cardId) {
        require(msg.value == changeFee);
        cards[_cardId].dna = _newDna;
        owner.transfer(msg.value);///
    }

    function changeJob(uint _cardId, uint8 _newJob) external payable onlyOwnerOf(_cardId) isDead(_cardId) {
        require(msg.value == changeFee);
        cards[_cardId].job = _newJob;
        owner.transfer(msg.value);///
    }

    function setChangeFee(uint _fee) external onlyOwner() { 
        changeFee = _fee;
    }

    function setCreationFee(uint _fee) external onlyOwner() { 
        creationFee = _fee;
    }

    function levelUp(uint _cardId) external isDead(_cardId) {
        cards[_cardId].level.add(1);
    }

    function recordExp(uint _cardId, uint40 _exp) external isDead(_cardId) {
        cards[_cardId].exp = _exp;
    }

    function revival(uint _cardId) external payable {
        require(msg.value == changeFee);
        cards[_cardId].dead = false;
        owner.transfer(msg.value);
    }

    function fightResult(uint _looseCard) external onlyOwnerOf(_looseCard) {
        cards[_looseCard].dead = true;
        emit Dead(_looseCard);
    }
}