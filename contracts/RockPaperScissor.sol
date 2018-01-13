pragma solidity ^0.4.18;

import './TurnBasedGame.sol';

contract RockPaperScissor is TurnBasedGame {

	enum options { Rock, Paper, Scissor }
	uint[] private UnmatchGameId;
    mapping(address => PlayerOptions) private OptionList;
    struct PlayerOptions{
        bytes32 encryptedOption;
        string key;
        options option;
    }

	function RockPaperScissor() public{
	}

	function play(bytes32 _encryptedOption, string _name) public payable {
	    //check user only send 0.1 ETH or have at least 0.1ETH in the balance. Also check user send encryptedOption
	    require((msg.value==100000000000000000 || Balance[msg.sender] > 1000000000000000000) && (_encryptedOption.length>1));
	    Balance[msg.sender] += msg.value;

	    //record the encrypted option
	    OptionList[msg.sender].encryptedOption = _encryptedOption;

		//first check if there is an existing game that need opponenet
		if(UnmatchGameId.length>0){
		    //find out the gameId from list:UnmatchGameId. Copy the last unmatchgameId then delete it from UnmatchGameId.
		    uint id = UnmatchGameId[UnmatchGameId.length-1];
		    delete UnmatchGameId[UnmatchGameId.length-1];

		    //player 2 join game, max number of player joined
		    addressToGameId[msg.sender] = id;
		    addPlayer(id, _name);
		    gameIdToGame[id].gameState = 2;
		    //Both players already submit their option, move to gameState 3 to request key to reveal
		    gameIdToGame[id].gameState = 3;
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

	function reveal(string _key, int _option) public checkGameState (3) {
	    Game memory current_game = getGame();
	    
        //record the key
        OptionList[msg.sender].key = _key;
        
        bool UnlockedValid = false;
        //check if they key is valid, it key is not valid, default lose
        if(keccak256(_key,_option)!=OptionList[msg.sender].encryptedOption) _DefaultLose(msg.sender);

        //check if both player reveal their key
        if((stringToBytes32(OptionList[current_game.players[0].player].key) != 0x0)&&(stringToBytes32(OptionList[current_game.players[1].player].key) != 0x0)){
            UnlockedValid = true;
            OptionList[msg.sender].option = intToOption(_option);
            //determine playerOne and playerTwo address
            if(current_game.players[0].player == msg.sender)_DecryptOption(current_game.players[1].player);
            else _DecryptOption(current_game.players[0].player);
        }
        // if both player option is unlock and valid, execute the game
	    if(UnlockedValid) ExeuteRockPaperScissor();
       
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
            Balance[winner] += game.jackpot;
            Balance[loser] -= game.jackpot;
            game.gameState = 4;
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
    
    //This function is called when the hash value does not match, default lose for sending incorrect key
    function _DefaultLose(address loser) private {
        Game storage game = getGame();
	    address winner;
	    
	    if(loser == game.players[0].player)winner = game.players[1].player;
	    else winner = game.players[0].player;

	    //we have hardcoded wager amount to be 0.1ETH
	    game.jackpot = 100000000000000000;
	    Balance[winner] += game.jackpot;
        Balance[loser] -= game.jackpot;
        game.gameState = 4;
        GameSessionEnded(winner,game.jackpot);
    }
    
    //this function convert string to byte32 for hash comparison
    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
        return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
    
    //This function convert 1 2 3 to Rock Paper Scissor;
    function intToOption(int _num) private pure returns(options) {
        if(_num == 1) return options.Rock;
        if(_num == 2) return options.Paper;
        if(_num == 3) return options.Scissor;
    }
    
    //This function Decrypt and record player option base on address given
    function _DecryptOption(address player) private {
        PlayerOptions memory playerOption = OptionList[player];
        int Rock = 1;
        int Paper = 2;
        int Scissor = 3;
        //string memory player_key = OptionList[player].key;
        //bytes32 memory player_hash =  OptionList[player].encryptedOption;
        if(playerOption.encryptedOption == keccak256(playerOption.key,Rock)) OptionList[player].option = options.Rock;
        else if(playerOption.encryptedOption == keccak256(playerOption.key,Paper)) OptionList[player].option = options.Paper;
        else if(playerOption.encryptedOption == keccak256(playerOption.key,Scissor)) OptionList[player].option = options.Scissor;
        else _DefaultLose(player);
    }
}
