// SPDX-License-Identifier: MIT
/**
 * @title DungeonsAndDragons
 * @author Maikel Ordaz
 * @notice A Dungeons And Dragons Game
 */

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "./DungeonHelper.sol";
import "./DungeonAdmin.sol";

error DungeonsAndDragons__NeedMoreEth();

contract DungeonsAndDragons is VRFConsumerBaseV2, ERC721URIStorage, DungeonHelper, DungeonAdmin {
    //////////////////////////
    // Chainlink variables //
    ////////////////////////

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    ////////////////////
    // NFT variables //
    //////////////////

    uint256 private immutable i_mintFee;
    uint256 private s_tokenCounter;

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

    /**
     * @notice A method to request new characters
     * @notice is a payable function
     * @dev it calls the VRF Cordinator for a random number
     * @param name The name of the new character
     */
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

    /**
     * @notice A function that receives the random number
     */

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

    function getNumberOfCharacters() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }
}
