// SPDX-License-Identifier: MIT
/**
 * @title DungeonHelper
 * @author Maikel Ordaz
 * @notice Just some helping functions
 */
pragma solidity ^0.8.8;

error DungeonHelper__OutOfBounds();

contract DungeonHelper {
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
        string name;
        uint256 strength;
        uint256 dexterity;
        uint256 constitution;
        uint256 intelligence;
        uint256 wisdom;
        uint256 charisma;
        uint256 experience;
        uint256 winCount;
        uint256 lossCount;
        bool readyToFight;
    }

    Character[] public characters;

    ////////////////////
    // NFT variables //
    //////////////////

    uint256 internal constant MAX_CHANCE = 100;

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
        revert DungeonHelper__OutOfBounds();
    }

    function getChanceArray() public pure returns (uint256[8] memory) {
        return [5, 10, 15, 20, 40, 60, 80, MAX_CHANCE];
    }

    function getLevel(uint256 tokenId) public view returns (uint256) {
        return sqrt(characters[tokenId].experience);
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
