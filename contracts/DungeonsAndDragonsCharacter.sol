// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error DungeonsAndDragons__NeedMoreEth();
error DungeonsAndDragons__OutOfBounds();
error DungeonsAndDragons__TransferFailed();

contract DungeonsAndDragons is VRFConsumerBaseV2, ERC721URIStorage, Ownable {
    //////////////////////////
    // Chainlink variables //
    ////////////////////////

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    //////////////////////////
    // Character variables //
    ////////////////////////

    enum Race {
        GREAT_ELF,
        GOD_KNIGHT,
        SUPER_ORC,
        SUPREME_WIZARD,
        ELF,
        KNIGHT,
        ORC,
        WIZARD
    }
    struct Character {
        uint256 strength;
        uint256 dexterity;
        uint256 constitution;
        uint256 intelligence;
        uint256 wisdom;
        uint256 charisma;
        uint256 experience;
        string name;
    }

    Character[] public characters;

    ////////////////////
    // NFT variables //
    //////////////////

    uint256 private immutable i_mintFee;
    uint256 private s_tokenCounter;
    //string[] internal s_characterUri;
    uint256 internal constant MAX_CHANCE = 100;

    ///////////////
    // Mappings //
    /////////////

    mapping(uint256 => address) public s_requestIdToSender;
    mapping(uint256 => string) public s_requestIdToCharacterName;

    /////////////
    // Events //
    ///////////

    event characterRequested(uint256 indexed requestId, address requester);
    event characterMinted(address minter, uint256 indexed tokenId, Race Race);

    //////////////////
    // Constructor //
    ////////////////

    constructor(
        address vrfCoordinatorV2,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        uint256 mintFee /*,
        string[8] memory characterUri*/
    ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("DungeonsAndDradonCharacter", "D&D") {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane; // KeyHash
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        i_mintFee = mintFee;
        //s_characterUri = characterUri;
    }

    /////////////////////
    // Main functions //
    ///////////////////

    function requestRandomCharacter(string memory name) public payable returns (uint256 requestId) {
        if (msg.value < i_mintFee) {
            revert DungeonsAndDragons__NeedMoreEth();
        }
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToCharacterName[requestId] = name;
        s_requestIdToSender[requestId] = msg.sender;
        emit characterRequested(requestId, msg.sender);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address characterOwner = s_requestIdToSender[requestId];
        s_tokenCounter++;
        uint256 newCharacterId = s_tokenCounter;
        uint256 modded = randomWords[0] % MAX_CHANCE;
        Race characterRace = getRaceFromModded(modded);
        uint256 strength = (randomWords[0] % 100);
        uint256 dexterity = ((randomWords[0] % 10000) / 100);
        uint256 constitution = ((randomWords[0] % 1000000) / 10000);
        uint256 intelligence = ((randomWords[0] % 100000000) / 1000000);
        uint256 wisdom = ((randomWords[0] % 10000000000) / 100000000);
        uint256 charisma = ((randomWords[0] % 1000000000000) / 10000000000);
        uint256 experience = 0;
        string memory name = s_requestIdToCharacterName[requestId];
        characters.push(
            Character(
                strength,
                dexterity,
                constitution,
                intelligence,
                wisdom,
                charisma,
                experience,
                name
            )
        );
        _safeMint(characterOwner, newCharacterId);
        //_setTokenURI(newCharacterId, s_characterUri[uint256(characterRace)]);
        emit characterMinted(characterOwner, newCharacterId, characterRace);
    }

    ///////////////////////
    // Getter functions //
    /////////////////////

    function getRaceFromModded(uint256 modded) public pure returns (Race) {
        uint256 cumulative = 0;
        uint256[8] memory chanceArray = getChanceArray();
        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (modded >= cumulative && modded < cumulative + chanceArray[i]) {
                return Race(i);
            }
            cumulative += chanceArray[i];
        }
        revert DungeonsAndDragons__OutOfBounds();
    }

    function getChanceArray() public pure returns (uint256[8] memory) {
        return [5, 10, 15, 20, 40, 60, 80, MAX_CHANCE];
    }

    /*
    function getCharacterUri(uint256 index) public view returns (string memory) {
        return s_characterUri[index];
    }
    */

    function getLevel(uint256 tokenId) public view returns (uint256) {
        return sqrt(characters[tokenId].experience);
    }

    function getNumberOfCharacters() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getCharacterName(uint256 tokenId) public view returns (string memory) {
        return (characters[tokenId].name);
    }

    function getCharacterStats(uint256 tokenId)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            characters[tokenId].strength,
            characters[tokenId].dexterity,
            characters[tokenId].constitution,
            characters[tokenId].intelligence,
            characters[tokenId].wisdom,
            characters[tokenId].charisma,
            characters[tokenId].experience
        );
    }

    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }

    /////////////////////////
    // Auxiliar functions //
    ///////////////////////

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    //////////////////////
    // Admin functions //
    ////////////////////

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert DungeonsAndDragons__TransferFailed();
        }
    }
}
