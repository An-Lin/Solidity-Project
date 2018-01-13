pragma solidity ^0.4.18;

import './TurnBasedGame.sol';

contract RockPaperScissor is TurnBasedGame {
	
	enum options { Rock, Paper, Scissor }    
	uint[] private UnmatchGameId;
    mapping(address => PlayerOptions) private OptionList;
    struct PlayerOptions{
        bytes32 encryptedOption;
        options option;
    }

	function RockPaperScissor() public{
	}

	function play(bytes32 _encryptedOption, string _name) payable public {
	    //check user only send 0.1 ETH or have at least 0.1ETH in the balance. Also check user send encryptedOption
	    require((msg.value==100000000000000000 || balance[msg.sender] > 1000000000000000000) && (_encryptedOption != ""));
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
    	    winner = _DetermineWinner(player_one,player_two);
    	    if(winner == player_one) 
    	        loser = player_two;
    	    else
    	        loser = player_one;
    	    GameSessionEnded(winner, game.jackpot);
            balance[winner] += game.jackpot;
            balance[loser] -= game.jackpot;
            GameSessionEnded(winner,game.jackpot);
	    }
	    game.jackpot = 0;
    }
    
    //This function would return winner address base on the option
    function _DetermineWinner(address _playerOne, address _playerTwo) private returns (address) {
        /*
            This looks horrible but got the job done
        */
         if(OptionList[ _playerOne].option == options.Scissor && OptionList[_playerTwo].option == options.Paper)
	            return _playerOne;
	    else if(OptionList[ _playerOne].option == options.Paper && OptionList[_playerTwo].option == options.Scissor)
	             return _playerTwo;        
	    else if(OptionList[ _playerOne].option == options.Rock && OptionList[_playerTwo].option == options.Scissor)
	             return _playerOne;
        else if(OptionList[ _playerOne].option == options.Scissor && OptionList[_playerTwo].option == options.Rock)
	            return _playerTwo;
        else if(OptionList[ _playerOne].option == options.Paper && OptionList[_playerTwo].option == options.Rock)
	             return  _playerOne;
        else if(OptionList[ _playerOne].option == options.Rock && OptionList[_playerTwo].option == options.Paper)
	             return _playerTwo;
    }
}
