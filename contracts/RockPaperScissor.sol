pragma solidity ^0.4.18;

import './TurnBasedGame.sol';

contract RockPaperScissor is TurnBasedGame {

	enum options { Rock, Paper, Scissor }
	uint[] private UnmatchGameId;
    mapping(address => PlayerOptions) private OptionList;
    struct PlayerOptions{
        string encryptedOption;
        options option;
    }

	function RockPaperScissor() public{
	}

	function play(string _encryptedOption, string _name) public payable {
	    //check user only send 0.1 ETH or have at least 0.1ETH in the balance. Also check user send encryptedOption
	    bytes memory tempEmptyStringTest = bytes(_encryptedOption);
	    require((msg.value==100000000000000000 || balance[msg.sender] > 1000000000000000000) && (tempEmptyStringTest.length>1));
	    balance[msg.sender] += msg.value;

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
	    address loser;

	    //we have hardcoded wager amount to be 0.1ETH
	    game.jackpot = 100000000000000000;

	    //if both player have the same option, no one wins
	    if(OptionList[player_one].option == OptionList[player_two].option ){
	        //brodcast draw result
	        GameSessionEnded(player_one,0);
	        GameSessionEnded(player_two,0);
	    }
	    else{
	        if(OptionList[ player_one].option == _DetermineWinner(OptionList[ player_one].option,OptionList[ player_two].option)){
	            winner = player_one;
	            loser = player_two;
	        }
    	    else{
    	        winner = player_one;
	            loser = player_two;
    	    }
    	        loser = player_one;
    	    GameSessionEnded(winner, game.jackpot);
            balance[winner] += game.jackpot;
            balance[loser] -= game.jackpot;
            GameSessionEnded(winner,game.jackpot);
	    }
	    game.jackpot = 0;
    }

    //This function would return winner option
    function _DetermineWinner(options _playerOne, options _playerTwo) private pure returns (options) {
        if(_playerOne == options.Scissor){
            if(_playerTwo == options.Paper) return _playerOne;
            if(_playerTwo == options.Rock) return _playerTwo;
        }
	    else if(_playerOne == options.Paper){
            if(_playerTwo == options.Rock) return _playerOne;
            if(_playerTwo == options.Scissor) return _playerTwo;
        }
	    else if(_playerOne == options.Rock){
            if(_playerTwo == options.Scissor) return _playerOne;
            if(_playerTwo == options.Paper) return _playerTwo;
        }
	    assert(false); // SANITY CHECK: We should never get here.
    }
}
