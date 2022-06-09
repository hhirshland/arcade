//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//need to find the best version of safemath
//import "./SafeMath.sol";
import "./Ownable.sol";


contract Arcade is Ownable {
    uint256 nowToDay = 86400;
    uint256 firstPlaceCut = 50;
    uint256 secondPlaceCut = 25;
    uint256 thirdPlaceCut = 10;
    uint256 takeRate = 100 - firstPlaceCut - thirdPlaceCut;
    uint256 costOfPlaying = 1e16; //1e16 = 0.01 eth
    address payoutWallet = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;

    mapping (address => uint) public arcadeTokensAvailable;
    mapping (uint => GameResult[]) public leaderboard;
    mapping (uint => bool) public dayHasBeenPaidOut;   

    //uint256 public contractBalance  = address(this).balance;
    //uint256 public myBalance = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4.balance;

    struct GameResult {
        string game;
        address player;
        uint256 dayPlayed;
        uint256 score;
    }

// example game results: "Flappybird",0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 69
// "Flappybird",0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 40
// "Flappybird",0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 20
    function submitGameResult(string memory _game, address _address, uint _score) public {
        require(arcadeTokensAvailable[msg.sender] > 0, "Sorry, you need to pay to play!");
        leaderboard[block.timestamp/nowToDay].push(GameResult(_game,_address,block.timestamp/nowToDay,_score));
        arcadeTokensAvailable[msg.sender]--;
    }

    function getDay() public view returns (uint256) {
        return block.timestamp/nowToDay;
    }

    //User deposits the game's cost to play, and then is able to play one game
    function payToPlay() payable public {
        require(msg.value == costOfPlaying);
        arcadeTokensAvailable[msg.sender]++;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function updateCostOfPlaying(uint _newCost) public onlyOwner {
        costOfPlaying = _newCost;
    }

    
    function getMyBalance() public view returns (uint256) {
        return arcadeTokensAvailable[msg.sender];
    }

    function dailyPayOut(uint256 _day) public payable {
        require(dayHasBeenPaidOut[_day] != true, "Sorry, this day's payout has already been distributed!");
        require(block.timestamp/nowToDay > _day, "Sorry, this day has not yet ended!");

        address firstPlace;
        uint256 firstPlaceScore = 0;
        address secondPlace;
        uint256 secondPlaceScore = 0;
        address thirdPlace;
        uint256 thirdPlaceScore = 0;
        uint256 totalPool;

        for (uint i = 0; i < leaderboard[_day].length ; i++) {
            totalPool+= costOfPlaying;
            if (leaderboard[_day][i].score > firstPlaceScore ) {
                thirdPlace = secondPlace;
                thirdPlaceScore = secondPlaceScore;
                secondPlace = firstPlace;
                secondPlaceScore = firstPlaceScore;
                firstPlace = leaderboard[_day][i].player;
                firstPlaceScore = leaderboard[_day][i].score;
            } else if (leaderboard[_day][i].score > secondPlaceScore) {
                thirdPlace = secondPlace;
                thirdPlaceScore = secondPlaceScore;
                secondPlace = leaderboard[_day][i].player;
                secondPlaceScore = leaderboard[_day][i].score;
            } else if (leaderboard[_day][i].score > thirdPlaceScore) {
                thirdPlace = leaderboard[_day][i].player;
                thirdPlaceScore = leaderboard[_day][i].score;
            }
        }

        uint firstPlacePrize = totalPool * firstPlaceCut / 100;
        uint secondPlacePrize = totalPool * secondPlaceCut / 100;
        uint thirdPlacePrize = totalPool * thirdPlaceCut / 100;
        uint take = totalPool * takeRate / 100;

        payable(firstPlace).transfer(firstPlacePrize);
        payable(secondPlace).transfer(secondPlacePrize);
        payable(thirdPlace).transfer(thirdPlacePrize);
        payable(payoutWallet).transfer(take);
        
        dayHasBeenPaidOut[_day] = true;
    }
    

}

