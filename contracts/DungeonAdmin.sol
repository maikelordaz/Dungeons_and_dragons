// SPDX-License-Identifier: MIT
/**
 * @title DungeonAdmin
 * @author Maikel Ordaz
 * @notice A Contract with functions only to be called by the owner of the contract
 */

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.8;

error DungeonAdmin__TransferFailed();

contract DungeonAdmin is Ownable {
    //////////////////////
    // Admin functions //
    ////////////////////

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert DungeonAdmin__TransferFailed();
        }
    }
}
