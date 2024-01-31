//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;
error Raffle_NotEnoughETHEntered();
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
error Raffle__TransferFailed();
contract Raffle is VRFConsumerBaseV2 {
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCooridnator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscrptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    //lottery variable
    address private s_recentWinner;

    event RaffleEnter(address indexed player);
    event requestRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    constructor(
        address vrfCoordinatorV2,
        uint256 entranceFee,
        bytes32 gasLane,
        uint64 subscrptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_vrfCooridnator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscrptionId = subscrptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function enterRaffle() public payable {
        require(msg.value >= i_entranceFee, "Raffle_NotEnoughETHEntered");
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }

    function requestRandomPlayer() external {
        uint256 requestId = i_vrfCooridnator.requestRandomWords(
            i_gasLane,
            i_subscrptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit requestRaffleWinner(requestId);
    }

    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] memory ranbdomWords
    ) internal override {
        uint256 indexofWinner = ranbdomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexofWinner];
        s_recentWinner=recentWinner;
      (bool success,) = recentWinner.call{value: address(this).balance}("");


        if (!success) {
            revert Raffle__TransferFailed();
        }
        emit WinnerPicked( recentWinner);
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }
    function getRecentWinner() public view returns(address){
        return s_recentWinner;
    }
}
