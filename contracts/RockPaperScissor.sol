pragma solidity ^0.4.18;

import './TurnBasedGame.sol';

contract RockPaperScissor is TurnBasedGame {
    
    uint[] private UnmatchGameId;
    
	function RockPaperScissor() public{
	}

	function play(bytes32 _encryptedOption, string _name) payable public {
	    //some basic check
	    require(msg.value > 0);
	    require(_encryptedOption!="");
	    
		//first check if there is existing game that need opponenet
		if(UnmatchGameId.length>0){
		    
		    //find out the game Id from list of UnmatchGameId
		    //copy the last unmatchgameId then delete the last it from UnmatchGameId list
		    uint id = UnmatchGameId[UnmatchGameId.length-1];
		    delete UnmatchGameId[UnmatchGameId.length-1];
		    
		    //player 2 join game and execute game
		    gameIdToGame[id].players.push(Player(msg.sender, _name));
		    execute_RockPaperScissor(id);

		}
		//if no avaliable game to join, start a fresh game
		else{
		     startGame(_name);
		}

	}

	function reveal(bytes32 _encryptedOption) public {
        require(_encryptedOption!="");

	    //decode the secret option

	    //compare the option and determin winner

	    //brodcast the result
	}
}
