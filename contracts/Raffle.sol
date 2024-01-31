//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;
error Raffle_NotEnoughETHEntered();

contract Raffle {
    uint256 private immutable i_entranceFee;
    address payable [] private s_players; 


    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function enterRaffle() public payable {
        require(msg.value >= i_entranceFee, "Raffle_NotEnoughETHEntered");
        s_players.push(payable(msg.sender));

         
    }
    function getPlayer(uint256 index) public view returns(address) {
      return s_players[index];

    }
}
