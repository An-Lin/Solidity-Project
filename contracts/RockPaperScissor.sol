//I design this contract to be first come first play, player do not get to choose who he is playing against. This will probably work but let me know if you think there is better way to implment this


pragma solidity ^0.4.18;
contract RockPaperScissor {
    
	//player construct 
    struct PlayerStruct {
        bytes32 encryptedOption;
        address addr;
    }

    //delcare two player
    PlayerStruct public player_one;
    PlayerStruct public player_two;

	
	function RockPaperScissor() public{
	    reset();
	}
	
	function play(bytes32 _encryptedOption) public {
	    //Scenario #1 First player enter the game
	    if(player_one.addr == address(0) && player_two.addr == address(0)){
	        player_one.addr=msg.sender;
	        player_one.encryptedOption = _encryptedOption;
	    }
	    //Scenario #2 Second player join in, signal the player to reveal
	    else{
	        player_two.addr=msg.sender;
	        player_two.encryptedOption = _encryptedOption;

	        //Event broadcast player can reveal now
	    }
	}
	
	function reveal(bytes32 _encryptedOption) public {

		//first check if both player properly populated with address and encryptedOption
		require()

	    //decode the secret option

	    //compare the option and determin winner

	    //brodcast the result
	    event()

	    reset();

	}
	
	//We call this function to reset the state of the contract
	function reset() private{
	    player_one = PlayerStruct("",address(0));
	    player_two = PlayerStruct("",address(0));
	}
}