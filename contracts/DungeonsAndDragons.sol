// SPDX-License-Identifier: MIT
/**
 * @title DungeonsAndDragons
 * @author Maikel Ordaz
 * @notice A Dungeons And Dragons Game
 */

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./DungeonAdmin.sol";
import "./DungeonsCharacterFactory.sol";

error DungeonsAndDragons__NeedMoreEth();

contract DungeonsAndDragons is DungeonAdmin, DungeonCharacterFactory, ReentrancyGuard {
    ///////////////////////
    // Global variables //
    /////////////////////

    uint256 private immutable i_mintFee;

    //////////////////
    // Constructor //
    ////////////////

    constructor(
        address vrfCoordinatorV2,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        uint256 mintFee
    ) DungeonCharacterFactory(vrfCoordinatorV2, gasLane, subscriptionId, callbackGasLimit) {
        i_mintFee = mintFee;
    }

    /////////////////////
    // Main functions //
    ///////////////////

    /**
     * @notice A method to mint new characters
     * @notice is a payable function
     * @dev it calls the VRF Cordinator for a random number
     * @param name The name of the new character
     */
    function mintCharacter(string memory name) public payable nonReentrant {
        if (msg.value < i_mintFee) {
            revert DungeonsAndDragons__NeedMoreEth();
        }
        requestRandomCharacter(name);
    }

    ///////////////////////
    // Getter functions //
    /////////////////////

    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }
}
