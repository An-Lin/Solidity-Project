pragma solidity ^0.4.18;

contract TurnBasedGame {
    mapping(address => uint) internal addressToGameId;
    mapping(uint => Game) internal gameIdToGame;
    mapping (address => uint) balance;
    uint internal gamesPlayed = 0;

    function TurnBasedGame() public {

    }

    event GameSessionCreated(uint gameId);
    event GameKeyReveal(uint gameId);
    event GameSessionEnded(address winner, uint gameJackPot);

    struct Player {
        address player;
        string playerAlias;
    }

    struct Game {
        Player[] players;
        uint gameState;
        uint jackpot;
        uint id;
    }

    function startGame(string name) internal {
        require(msg.value > 0);
        /*
        TODO - Locks
        */
        Game storage game = gameIdToGame[gamesPlayed];
        game.players.push(Player(msg.sender, name));
        game.gameState = 0;
        game.jackpot = msg.value;
        game.id = gamesPlayed;
        
        addressToGameId[msg.sender] = gamesPlayed;

        //notify game created
        GameSessionCreated(gamesPlayed);
        //increment gameId
        gamesPlayed++;
    }

    function getGameId() internal view returns (uint){
        uint id = addressToGameId[msg.sender];
        require(id != 0);
        return id;
    }

    function withdraw() public {
        uint amount = balance[msg.sender];
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        balance[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}
