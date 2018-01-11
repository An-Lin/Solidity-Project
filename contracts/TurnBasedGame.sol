pragma solidity ^0.4.18;

contract TurnBasedGame {
    enum GameState { Begin, Locked, Over }
    mapping(uint => Game) private unMatchedGames;
    mapping(address => uint) private addressToGameId;
    mapping(uint => Game) private gameIdToGame;
    uint private gamesPlayed = 0;

    function TurnBasedGame() public {

    }

    event GameHasBegun(uint gameId);
    event GameHasEnded(string winnerAlias, uint gameJackPot);

    struct Player {
        address player;
        string playerAlias;
    }

    struct Game {
        Player[] players;
        GameState state;
        uint jackpot;
        uint id;
    }


    function startGame(string name) internal {
        require(msg.value > 0);
        /*
        TODO - Locks
        */
        Game memory game;
        gameIdToGame[gamesPlayed] = game;
        gameIdToGame[gamesPlayed].players.push(Player(msg.sender, name));
        addressToGameId[msg.sender] = gamesPlayed;
    }

    function getGameId() internal view returns (uint){
        uint id = addressToGameId[msg.sender];
        require(id != 0);
        return id;
    }
}
