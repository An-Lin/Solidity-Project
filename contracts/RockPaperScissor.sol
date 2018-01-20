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
    PlayerOptions blank;

	function RockPaperScissor() public{
	}

	function getGamesPlayed() external view returns (uint) {
		return gamesPlayed;
	}

	function fireEvents() public {
		GameSessionCreated(1234);
	    GameKeyReveal(4321);
	    GameSessionEnded(address(0), 2000000000000000000);
	    CheckPoint(404);
	    RevealValidTime(now);
	}

	function play(bytes32 _encryptedOption, string _name) public payable returns (uint ret) {
	    //check user only send 0.1 ETH or have at least 0.1ETH in the balance. Also check user send encryptedOption
		CheckPoint(1); // Made it into the function
		Game memory check_game = getGame();
		require(check_game.gameState == 4 || check_game.gameState == 0);
		require(msg.value==100000000000000000 || Balance[msg.sender] > 1000000000000000000);
	    require(_encryptedOption.length > 1);
	    Balance[msg.sender] += msg.value;

	    //record the encrypted option
	    OptionList[msg.sender].encryptedOption = _encryptedOption;

		//first check if there is an existing game that need opponenet
		if(UnmatchGameId.length>0){
		    //find out the gameId from list:UnmatchGameId. Copy the last unmatchgameId then delete it from UnmatchGameId.
		    uint id = UnmatchGameId[UnmatchGameId.length-1];
		    delete UnmatchGameId[UnmatchGameId.length-1];
		    UnmatchGameId.length --;

		    //player 2 join game, max number of player joined
		    addressToGameId[msg.sender] = id;
		    addPlayer(id, _name);
		    //we have hardcoded wager amount to be 0.1ETH
		    gameIdToGame[id].jackpot+=100000000000000000;
		    Balance[msg.sender] -= 100000000000000000;
		    //we can skip setting gameState to 2 since we have user input when joined game
		    //gameIdToGame[id].gameState = 2;
		    //Both players already submit their option, move to gameState 3 to request key to reveal
		    gameIdToGame[id].gameState = 3;
		    //send event to notify user to call reveal()
		    GameKeyReveal(id);
		    //record valid time for reveal
		    gameIdToGame[id].validTime = (now + 30 minutes);

		    //send event request user to reply within this time
		    RevealValidTime(now + 30 minutes);
            return 2;
		}
		//if no avaliable game to join, start a fresh game and add that to unmatchGame list
		else if (UnmatchGameId.length == 0 ){
		    OptionList[msg.sender].encryptedOption = _encryptedOption;
		    startGame(_name);
		    UnmatchGameId.push(gamesPlayed);
            return 1;
		}
	}

	function reveal(string _key, uint _option) public checkGameState (3) {
	    Game memory current_game = getGame();
	    require(current_game.gameState == 3 && current_game.validTime !=0);

        //record the key
        OptionList[msg.sender].key = _key;

        bool UnlockedValid = false;
        string memory tempStringOption;
        if(_option==uint(1)) tempStringOption="1";
        else if(_option==uint(2)) tempStringOption="2";
        else if(_option==uint(3)) tempStringOption="3";
        else{
        	_DefaultLose(msg.sender);
        	CheckPoint(1);
        }

        //check if they key is valid, it key is not valid, default lose
        if(keccak256(_key,tempStringOption)!=OptionList[msg.sender].encryptedOption){
         	_DefaultLose(msg.sender);
        	CheckPoint(2);
		}


        //if your oponent did not reveal within the time frame
        else if(now>current_game.validTime){
        	_DefaultWin(msg.sender);
        	CheckPoint(3);
        }

        //check if both player reveal their key
        else if((stringToBytes32(OptionList[current_game.players[0].player].key) != 0x0)&&(stringToBytes32(OptionList[current_game.players[1].player].key) != 0x0)){
        	CheckPoint(4);
            UnlockedValid = true;
            OptionList[msg.sender].option = intToOption(_option);
            //determine playerOne and playerTwo address
            if(current_game.players[0].player == msg.sender)_DecryptOption(current_game.players[1].player);
            else _DecryptOption(current_game.players[0].player);
        }
        // if both player option is unlock and valid, execute the game
	    if(UnlockedValid){
	    	CheckPoint(5);
	    	ExeuteRockPaperScissor();
	    }
		else{
			WaitingForPlayer2(true);
		}

	}


    // execute the game after we decode both player option
    function ExeuteRockPaperScissor() private {
        Game storage game = getGame();

	    address player_one = game.players[0].player;
	    address player_two = game.players[1].player;
	    address winner;
	    address loser;

	    //if both player have the same option, no one wins
	    if(OptionList[player_one].option == OptionList[player_two].option ){
	        //brodcast draw result
	        GameSessionEnded(player_one,0);
	        GameSessionEnded(player_two,0);
	        Balance[player_one] += 100000000000000000;
	        Balance[player_two] += 100000000000000000;
	        GameSessionEnded(winner,uint(0));
	    }
	    else{
	        if(OptionList[ player_one].option == _DetermineWinner(OptionList[player_one].option,OptionList[player_two].option)){
	            winner = player_one;
	            loser = player_two;
	        }
    	    else{
    	        winner = player_two;
	            loser = player_one;
    	    }
    	    game.winner=winner;
            Balance[winner] += game.jackpot;
            GameSessionEnded(winner,game.jackpot);
	    }
	    game.gameState = 4;
	    game.jackpot = 0;
	    OptionList[player_two]=blank;
	    OptionList[player_one]=blank;
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

	    game.winner=winner;
	    Balance[winner] += game.jackpot;
        game.gameState = 4;
        GameSessionEnded(winner,game.jackpot);
        game.jackpot = 0;
	    OptionList[game.players[0].player]=blank;
	    OptionList[game.players[1].player]=blank;
    }

    //This function is called when the opponent did not call reveal() within x time, default win sender
    function _DefaultWin(address winner) private {
        Game storage game = getGame();
	    address loser;

	    if(winner == game.players[0].player) loser = game.players[1].player;
	    else loser = game.players[0].player;

	    game.winner=winner;
	    Balance[winner] += game.jackpot;
        game.gameState = 4;
        GameSessionEnded(winner,game.jackpot);
        game.jackpot = 0;

	    OptionList[game.players[0].player]=blank;
	    OptionList[game.players[1].player]=blank;
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
    function intToOption(uint _num) private pure returns(options) {
        if(_num == 1) return options.Rock;
        if(_num == 2) return options.Paper;
        if(_num == 3) return options.Scissor;
    }

    //This function Decrypt and record player option base on address given
    function _DecryptOption(address player) private {
        PlayerOptions memory playerOption = OptionList[player];
        string memory Rock = "1";
        string memory Paper = "2";
        string memory Scissor = "3";

        //string memory player_key = OptionList[player].key;
        //bytes32 memory player_hash =  OptionList[player].encryptedOption;
        if(playerOption.encryptedOption == keccak256(playerOption.key,Rock)) OptionList[player].option = options.Rock;
        else if(playerOption.encryptedOption == keccak256(playerOption.key,Paper)) OptionList[player].option = options.Paper;
        else if(playerOption.encryptedOption == keccak256(playerOption.key,Scissor)) OptionList[player].option = options.Scissor;
        else _DefaultLose(player);
    }

    //Player can cancel game if nobody join after X amount of time (Eg X=1 hour). This function have to be game specific since each game have their own UnmatchGameId
    function cancelGame(uint id) public {
        Game storage game= gameIdToGame[id];
        require(game.gameState ==1 && game.players[0].player == msg.sender && now>(game.createdTime + 1 hours));
        Balance[msg.sender] += game.jackpot;
        game.gameState=4;
        GameSessionEnded(msg.sender,game.jackpot);
        game.jackpot = 0;
        //remove game from unmatch, right now we assume it is the latest
        require(id == UnmatchGameId[UnmatchGameId.length-1]);
        delete UnmatchGameId[UnmatchGameId.length-1];
		UnmatchGameId.length --;
    }
}
