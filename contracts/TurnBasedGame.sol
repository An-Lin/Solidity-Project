pragma solidity ^0.4.18;

contract TurnBasedGame {
    mapping(address => uint) internal addressToGameId;
    mapping(uint => Game) internal gameIdToGame;
    mapping (address => uint) Balance;
    uint internal gamesPlayed = 0;

    function TurnBasedGame() public {

    }

    event GameSessionCreated(uint gameId);
    event GameKeyReveal(uint gameId);
    event GameSessionEnded(address winner, uint gameJackPot);
    event CheckPoint(uint error);
    event RevealValidTime(uint time);
    event Check1(uint error);
    event Check2(uint error);
    event Check3(uint error);
    event Check4(uint error);
    event Check5(uint error);


    struct Player {
        address player;
        string playerAlias;
    }

    struct Game {
        Player[] players;
        uint gameState;
        uint jackpot;
        uint id;
        uint validTime;
    }

    function startGame(string name) internal {
        Game memory game_check = getGame();
        require(game_check.gameState ==4 || game_check.gameState ==0);
        //increment gameId
        Game storage game = gameIdToGame[++gamesPlayed];
        // game id '0' will be reserved and represent a fresh contract.
        assert(gamesPlayed > 0);
        game.players.push(Player(msg.sender, name));
        game.gameState = 1;
        game.jackpot = msg.value;
        game.id = gamesPlayed;

        addressToGameId[msg.sender] = gamesPlayed;

        //notify game created
        GameSessionCreated(gamesPlayed);
    }

    function getGameId() internal view returns (uint){
        uint id = addressToGameId[msg.sender];
        return id;
    }

    function getGame() internal view returns (Game storage id){
        return gameIdToGame[getGameId()];
    }

    function addPlayer(uint _gameID, string _name) internal {
        addressToGameId[msg.sender] = _gameID;
        gameIdToGame[_gameID].players.push(Player(msg.sender, _name));
    }

    function withdraw() public {
        uint amount = Balance[msg.sender];
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        Balance[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function deposit() payable public {
        require(msg.value>0);
        Balance[msg.sender] += msg.value;
    }


    modifier checkGameState (uint _gameState){
        require(getGame().gameState ==  _gameState);
        _;
    }

    function getPlayerStatus() external view returns(uint gameId, uint gameState, uint gameJackPot){
        Game memory temp_game = getGame();
        gameId =  temp_game.id;
        gameState =  temp_game.gameState;
        gameJackPot =  temp_game.jackpot;
    }
}
