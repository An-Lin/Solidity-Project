pragma solidity ^0.4.18;

import './TurnBasedGame.sol';

contract RockPaperScissor is TurnBasedGame {

    uint[] private UnmatchGameId;
    mapping(address => PlayerOptions) private OptionList;
    struct PlayerOptions{
        bytes32 encryptedOption;
        bytes32 option;
    }

	function RockPaperScissor() public{
	}

	function play(bytes32 _encryptedOption, string _name) payable public {
	    //check user only send 0.1 ETH
	    require(msg.value==100000000000000000);
	    balance[msg.sender] += msg.value;
	    require(balance[msg.sender] > 0 && _encryptedOption != "");

	    //record the encrypted option
	    OptionList[msg.sender].encryptedOption = _encryptedOption;

		//first check if there is an existing game that need opponenet
		if(UnmatchGameId.length>0){
		    //find out the gameId from list:UnmatchGameId. Copy the last unmatchgameId then delete it from UnmatchGameId.
		    uint id = UnmatchGameId[UnmatchGameId.length-1];
		    delete UnmatchGameId[UnmatchGameId.length-1];

		    //player 2 join game
		    addPlayer(id, _name);
		    //send event to notify user to call reveal()
		    GameKeyReveal(id);
		}
		//if no avaliable game to join, start a fresh game and add that to unmatchGame list
		else{
		    OptionList[msg.sender].encryptedOption = _encryptedOption;
		    startGame(_name);
		    UnmatchGameId.push(gamesPlayed);
		}
	}

	function reveal(/*uint id, bytes32 key*/) public {
	    /*
        TODO - check only players in that game(id) can trigger this function
        TODO - recieve key to unlock Optionlist. if hash doent match, automatically lose
        */

        // if both player option is unlock, execute the game
	    bool condition = true;
	    if(condition){
	        ExeuteRockPaperScissor();
	    }
	}

    // execute the game after we decode both player option
    function ExeuteRockPaperScissor() private {
        Game storage game = getGame();

	    address player_one = game.players[0].player;
	    address player_two = game.players[1].player;
	    address winner;

	    //we have hardcoded wager amount to be 0.1ETH
	    game.jackpot = 200000000000000000;

	    //if both player have the same option
	    if(OptionList[player_one].option == OptionList[player_two].option ){
	        //brodcast draw result
	        GameSessionEnded(player_one,100000000000000000);
	        GameSessionEnded(player_two,100000000000000000);
	    }

	    else{

            /*
            TODO - decide the winner if it is not a draw
            */

    	    //brodcast the result
    	    GameSessionEnded(winner,getGame().jackpot);
            balance[winner] += getGame().jackpot;
	    }
	    getGame().jackpot=0;
    }
}
