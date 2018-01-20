
var game = (function(){
    var sleep = require('sleep');
    var rps, p1account = 1, p2account = 2, p1pass = "player1", p2pass = "player2", p1choice = 1, p2choice = 2;
    function log(val){
        console.log(val);;
    }
    return {
        init: function(address){
            if (address === undefined) {
                address = "0x345ca3e014aaf5dca488057592ee47305d9b3e10";
            }
            console.log("RPS connected at: " + address);
            rps = RockPaperScissor.at(address);
        },
        play: function(){
            rps.play(web3.sha3(p1pass + p1choice), "player_1", {from: web3.eth.accounts[p1account], value: 100000000000000000, gas: 2100000}).then(log);
            sleep.sleep(1);
            rps.play(web3.sha3(p2pass + p2choice), "player_2", {from: web3.eth.accounts[p2account], value: 100000000000000000, gas: 2100000}).then(log);
        },
        reveal: function(){
            rps.reveal(p1pass, p1choice, {from: web3.eth.accounts[p1account], gas: 2100000}).then(log);
            sleep.sleep(1);
            rps.reveal(p2pass, p2choice, {from: web3.eth.accounts[p2account], gas: 2100000}).then(log);
        },
        withdraw: function(account){
            rps.withdraw({from: web3.eth.accounts[account], gas: 2100000}).then(log);
        },
        changeAccount: function(p1, p2){
            p1account = p1;
            p2account = p2;
        },
        changeChoice: function(p1, p2){
            p1choice = p1;
            p2choice = p2;
        },
        rpsinstance: function(){
            return rps;
        },
        help: function(){
            console.log("init: (string) contract address if not 0x345ca3e014aaf5dca488057592ee47305d9b3e10\nplay: ()\nreveal: ()\nwithdraw: (int account) - default accounts are 1 and 2\nchangeChoice: (int) player 1 choice, (int) player 2 choice\nrpsinstance: ()  gets raw instance.");
        }
    }
})();
game.init();
