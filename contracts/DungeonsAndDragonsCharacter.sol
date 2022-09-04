// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DungeonAndDragonCharacter is ERC721 {
    //////////////////////////
    // Character variables //
    ////////////////////////

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

    //////////////////
    // Constructor //
    ////////////////
    constructor() ERC721("DungeonsAndDradonCharacter", "D&D") {}

    ////////////////////
    // Main functions //
    ///////////////////

    ///////////////////////
    // Getter functions //
    /////////////////////

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        return tokenURI(tokenId);
    }

    function getLevel(uint256 tokenId) public view returns (uint256) {
        return sqrt(characters[tokenId].experience);
    }

    function getNumberOfCharacters() public view returns (uint256) {
        return sqrt(characters.length);
    }

    function getCharacterOverview(uint256 tokenId) public view returns (string memory, uint256) {
        return (characters[tokenId].name, getLevel(tokenId));
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
}
