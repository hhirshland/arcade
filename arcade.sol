pragma solidity ^0.8.13;

import "./SafeMath.sol";


contract Arcade {
    using SafeMath for uint256;

    uint nowToDay = 86400;
    uint costOfPlaying = 0.01 ether; //temporary cost of playing... to be upgraded to ArcadeToken later
    uint firstPlaceCut = 50;
    uint secondPlaceCut = 25;
    uint thirdPlaceCut = 1;
    uint takeRate = 1 - firstPlaceCut - secondPlaceCut - thirdPlaceCut;

    mapping (address => uint) arcadeTokensAvailable;
    mapping (uint => gameResult[]) leaderboard;
    mapping (uint => bool) dayHasBeenPaidOut;

    //should I add an event for gamePlayed?

    //gameResult is the struct formatted to store all game result data.
    //When a user plays a game, upon completion they will trigger an event that should
    //create a new gameResult, and store it in the daily leaderboard.
    struct gameResult {
        string game;
        address player;
        uint dayPlayed;
        uint score;
    }

    //add a require that checks that the address is whitelisted, by being on a mapping 
    //to get whitelisted you must have spent one token, and not have already used it
    //TO DO: FIGURE OUT HOW TO ENSURE THIS ISN'T EXPLOITED BY USER ENTERING IN SCORE MANUALLY?!
    function submitGameResult(string memory _game, address _address, uint _score) public {
       
        //check to make sure the user has an available token to use (confirms they have spent a token to play)
        require(arcadeTokensAvailable[_address] > 0);

        //Add the submitted game result to today's leaderboard
        leaderboard[block.timestamp/nowToDay].push(gameResult(_game,_address,block.timestamp/nowToDay,_score));
        
        //remove the token available from the user's address, since it was 'used.'
        arcadeTokensAvailable[_address].sub(1);

        //should I emit a gamePlayed event?
    }

    function payToPlay(address _address) public payable {
        require(msg.value == costOfPlaying);
        //If the user has paid the required fee, give them a token so they can submitGameResult
        arcadeTokensAvailable[_address].add(1);
    }

    function payOut(uint _day) public {
        require(dayHasBeenPaidOut[_day] != true);
        address firstPlace;
        uint firstPlaceScore = 0;
        address secondPlace;
        uint secondPlaceScore = 0;
        address thirdPlace;
        uint thirdPlaceScore = 0;
        uint totalPool;

        //should _day be block.timestamp/nowToDay ?!

        for (uint i = 0; i < leaderboard[_day].length ; i++) {
            totalPool.add(1);
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
        //where to send take?  presumably some multi-sig or use 0xsplit
        
        dayHasBeenPaidOut[_day] = true;


    } 

    //Should I use this instead of doing this in submitGameResult?  Might actually be better to do within
    //function to reduce possibility of exploiting.
    modifier hasArcadeTokensAvailable (address _address) {
        require(arcadeTokensAvailable[_address] > 0);
        _;
    }
}