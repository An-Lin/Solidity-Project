pragma solidity ^0.4.18;

contract TurnBasedGame {
    mapping(address => uint) internal addressToGameId;
    mapping(uint => Game) internal gameIdToGame;
    mapping (address => uint) pendingWithdrawals;
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
        Game memory game;
        gameIdToGame[gamesPlayed] = game;
        gameIdToGame[gamesPlayed].players.push(Player(msg.sender, name));
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
        uint amount = pendingWithdrawals[msg.sender];
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}
pragma solidity ^0.4.18;

contract TurnBasedGame {
    mapping(address => uint) internal addressToGameId;
    mapping(uint => Game) internal gameIdToGame;
    mapping (address => uint) pendingWithdrawals;
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
        Game memory game;
        gameIdToGame[gamesPlayed] = game;
        gameIdToGame[gamesPlayed].players.push(Player(msg.sender, name));
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
        uint amount = pendingWithdrawals[msg.sender];
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}
