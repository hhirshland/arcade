//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract Arcade {

    uint256 nowToDay = 86400;

    //How to deal with the number / decimal formatting??!
    uint256 costOfPlaying = 10000000000000000;
    uint256 public contractBalance  = address(this).balance;
    uint256 public myBalance = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4.balance;


    struct GameResult {
        string game;
        address player;
        uint256 dayPlayed;
        uint256 score;
    }

    mapping (address => uint) arcadeTokensAvailable;
    mapping (uint => GameResult[]) public leaderboard;
    mapping (uint => bool) dayHasBeenPaidOut;   


    function submitGameResult(string memory _game, address _address, uint _score) public {


        leaderboard[block.timestamp/nowToDay].push(GameResult(_game,_address,block.timestamp/nowToDay,_score));


    }

    function getDay() public view returns (uint256) {
        return block.timestamp/nowToDay;
    }

    //I CANT FIGURE OUT HOW TO GET THIS TO WORK!
    function payToPlay(uint256 _amount) payable public {
        //require(msg.value == costOfPlaying);
        


    }



}

// "Flappybird",0xbA88168Abd7E9d53A03bE6Ec63f6ed30d466C451, 69