// SPDX-License-Identifier: MIT
/**
 * @title AdminContract
 * @notice A Contract with functions only to be called by the owner of the contract
 */

import "@openzeppelin/contracts/access/Ownable.sol";

error DungeonsAndDragons__TransferFailed();

contract AdminContract is Ownable {
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
