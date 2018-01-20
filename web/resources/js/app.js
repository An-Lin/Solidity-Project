var App = (function() {
    var UIController = (function() {
        'use strict';
        const MINIMUM_PASSWORD_LENGTH = 3; // CHANGE FOR PRODUCTION
        const MINIMUM_USERNAME_LENGTH = 3; // CHANGE FOR PRODUCTION
        var bet_amount = '0.1'; // CHANGE FOR PRODUCTION
        var $nonce, $username, $playButton, $userChoice;

        var RPS = {
            ROCK: 1,
            PAPER: 2,
            SCISSOR: 3,
        }

        function attachUIListeners() {
            $nonce = $("#nonce");
            $username = $("#username");
            $playButton = $("#play-button");
        }

        return {
            init: function() {
                attachUIListeners();
                this.clear();
            },
            clear: function() {
                $nonce.val("");
            },
            validPassword: function() {
                var result = $nonce.val().length >= MINIMUM_PASSWORD_LENGTH;
                if (result) {
                    return true;
                }
                alert("Please choose a password!");
                return false;
            },
            getPassword: function() {
                return $nonce.val();
            },
            validUsername: function() {
                var result = $username.val().length >= MINIMUM_USERNAME_LENGTH;
                if (result) {
                    return true;
                }
                alert("Please choose a username!");
                return false;
            },
            getUsername: function() {
                return $username.val();
            },
            getAmount: function() {
                return bet_amount;
            },
            userCanPlay: function() {
                return this.validPassword() && this.validUsername();
            },
            attachPlayButtonClickListener: function(func) {
                $playButton.click(func);
            },
            getUserChoice: function() {
                return $('#rps-choice input:radio:checked').val();
            },
            triggerModal: function(){
                $('#gameResultModal').modal('show');
            },
            win: function(){
                alert("You Won!");
            },
            loss: function(){
                alert("You Lost.. Better luck next time.");
            },
        }
    })();

    var GameController = (function() {
        'use strict';
        const SECONDS = 1000;
        var mode = 0;
        var user;
        var choice;
        var pass;

        function timeout() {
            setTimeout(function() {
                if (!App.checkForPlayerJoined() || !App.checkForPlayerReveal()) {
                    timeout();
                }
            }, 20 * SECONDS);
        }

        return {
            modes: function(){
                return {
                    IDLE:0,
                    WAITING:1,
                    REVEAL:2,
                    WAITING_REVEAL: 3,
                    ENDGAME: 4
                }
            },
            getMode: function(){
                return mode;
            },
            setMode: function(val){
                mode = val;
                switch (mode) {
                    case GameController.modes().WAITING:
                    case GameController.modes().WAITING_REVEAL:
                        timeout();
                        break;
                    case GameController.modes().REVEAL:
                        App.reveal();
                        break;
                    case GameController.modes().ENDGAME:
                        UIController.clear();
                        setMode(GameController.modes().IDLE);
                        break;
                    default:

                }
            }
        }
    })();

    const CONTRACTS = ["RockPaperScissor"];


    var debug_mode = true;

    function debug(str) {
        if (debug_mode) {
            console.log(str);
        }
    }

    function checkResult(result){
        if (result === web3.eth.accounts[0]) {
            UIController.win();
            GameController.setMode(GameController.modes().ENDGAME);
        } else if (result === '0x0000000000000000000000000000000000000000') {
            UIController.loss();
            GameController.setMode(GameController.modes().ENDGAME);
        }
    }

    return {
        web3Provider: null,
        contracts: {},
        address: {rps: null},
        events: {
            GameSessionCreated: null,
            GameKeyReveal: null,
            GameSessionEnded: null,
            CheckPoint: null,
            RevealValidTime: null,
        },

        init: function() {
            debug("Initializing Web App.");
            return App.initWeb3();
        },
        initWeb3: function() {
            debug("Connecting to Web3 Provider..");
            // Initialize web3 and set the provider
            HelperUtil.initWeb3(App);
            return App.initContract();
        },

        initContract: function() {
            debug("Retrieving Smart Contract Artifacts...");
            for (var i = 0; i < CONTRACTS.length; i++) {
                (function(i){
                    var currentContract = CONTRACTS[i];
                    $.getJSON('/web/contracts/' + currentContract + ".json", function(data) {
                        // Get the necessary contract artifact file and instantiate it with truffle-contract.
                        debug("Connection Established to: " + currentContract);
                        App.contracts[currentContract] = TruffleContract(data);
                        // Set the provider for our contract.
                        App.contracts[currentContract].setProvider(App.web3Provider);
                        debug(currentContract + " Artifact Saved.");
                        if (i == CONTRACTS.length -1) {
                            return App.bindEvents();
                        }
                    });
                })(i);
            }

            return true;
        },
        callContract: function(debugmsg, funcs){
                debug(debugmsg.M1);
                App.contracts.RockPaperScissor.deployed().then(funcs.call).then(function(result){
                    debug(debugmsg.M2);
                    return result;
                }).then(funcs.callback).catch(function(err) {
                    debug(err.message);
                });
        },
        play: function() {
            if (UIController.userCanPlay()) {
                var dbg = {
                    M1: "User playing game..",
                    M2: "Received Result: ",
                }
                var funcs = {
                    call: function(instance){
                        user = UIController.getUsername();
                        choice = UIController.getUserChoice();
                        pass = web3.sha3(UIController.getPassword() + choice);
                        return instance.play(pass, user, {from: web3.eth.accounts[0],value: web3.toWei(UIController.getAmount(), 'ether')});
                    },
                    callback: function(result){
                        for (var i = 0; i < result.logs.length; i++) {
                            var log = result.logs[i];
                            switch (log.event) {
                                case "GameKeyReveal":
                                    alert("Joined Existing Game.");
                                    GameController.setMode(GameController.modes().REVEAL);
                                    break;
                                case "GameSessionCreated":
                                    alert("Created New Game.");

                                    GameController.setMode(GameController.modes().WAITING);
                                    break;
                                default:
                            }
                          }
                          debug(result);
                    }
                }
                App.callContract(dbg, funcs);
            }
        },
        reveal: function() {
        if (GameController.getMode() == GameController.modes().REVEAL) {
            var dbg = {
                M1: "Revealing hand..",
                M2: "Received Result: ",
            }
            var funcs = {
                call: function(instance) {
                    choice = UIController.getUserChoice();
                    pass = UIController.getPassword();
                    return instance.reveal(pass, choice);
                },
                callback: function(result) {
                    for (var i = 0; i < result.logs.length; i++) {
                        var log = result.logs[i];
                        switch (log.event) {
                            case "GameSessionEnded":
                                checkResult(log.args.winner);
                                debug(log.event);
                                break;
                            case "WaitingForPlayer2":
                                debug(log.event);
                                GameController.setMode(GameController.modes().WAITING_REVEAL);
                                break;
                            default:

                        }
                    }
                    debug(result);
                }
            }
            App.callContract(dbg, funcs);
        }},
        checkForPlayerJoined: function() {
            if (GameController.getMode() == GameController.modes().WAITING) {
                var dbg = {
                    M1: "Getting Player Status",
                    M2: "Received Result: ",
                }
                var funcs = {
                    call: function(instance) {
                        return instance.getPlayerStatus();
                    },
                    callback: function(result) {
                        debug(result);

                        if (result[1].c[0] === 3) {
                            GameController.setMode(GameController.modes().REVEAL);
                        }
                    }
                }
                App.callContract(dbg, funcs);
                return GameController.getMode() != GameController.modes().WAITING;
            }
            return false;
        },
        checkForPlayerReveal: function() {
            if (GameController.getMode() == GameController.modes().WAITING_REVEAL) {
                var dbg = {
                    M1: "Waiting On Player Two",
                    M2: "Received Result: ",
                }
                var funcs = {
                    call: function(instance) {
                        return instance.getCurrentGameWinner();
                    },
                    callback: function(result) {
                        checkResult(result[0].c[0]);
                    }
                }
                App.callContract(dbg, funcs);
                return GameController.getMode() != GameController.modes().WAITING_REVEAL;
            }
            return false;
        },
        bindEvents: function() {
            UIController.init();
            UIController.attachPlayButtonClickListener(this.play);
            var dbg = {
                M1: "Initializing event listeners..",
                M2: "Initialized..",
            }
            var funcs = {
                call: function(instance) {
                    App.address.rps = instance.address;
                    var temp = App.contracts.RockPaperScissor.at(instance.address);
                    function logFunc(err, res){
                        console.log(res);
                    }
                    App.events.CheckPoint = temp.CheckPoint().watch(logFunc);
                    App.events.GameSessionCreated = temp.GameSessionCreated().watch(logFunc);
                    App.events.GameKeyReveal = temp.GameKeyReveal().watch(logFunc);
                    App.events.GameSessionEnded = temp.GameSessionEnded().watch(logFunc);
                    App.events.RevealValidTime = temp.RevealValidTime().watch(logFunc);
                    return instance;
                },
                callback: function(result) {
                    return result;
                }
            }
            App.callContract(dbg, funcs);
        }
    }
})();

$(window).on('load', function() {
    App.init();
});
