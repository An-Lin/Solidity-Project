var App = (function() {
    var UIController = (function() {
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
            }
        }
    })()


    const CONTRACTS = ["RockPaperScissor"];


    var debug_mode = true;

    function debug(str) {
        if (debug_mode) {
            console.log(str);
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
        play: function() {
            if (UIController.userCanPlay()) {
                //AJAX call
                debug("User playing game..");

                var RockPaperScissorInstance;

                App.contracts.RockPaperScissor.deployed().then(function(instance) {
                    debug("RPS: Deployed instance recieved.");
                    RockPaperScissorInstance = instance;
                    user = UIController.getUsername();
                    choice = UIController.getUserChoice();
                    pass = web3.sha3(UIController.getPassword() + choice);
                    // debug(pass, user, amount);
                    checkpoint = RockPaperScissorInstance.RevealValidTime();
                    checkpoint.watch(function(error, result) {
                        if (error) {
                            console.log(error);
                        } else {
                            console.log("Checkpoint!");
                        }
                    });
                    debugger;
                    debug("Calling Play.");
                    return RockPaperScissorInstance.play(pass, user, {from: web3.eth.accounts[0],value: web3.toWei(UIController.getAmount(), 'ether')});
                }).then(function(result) {
                    checkpoint.watch(function(error, result) {
                        if (error) {
                            console.log(error);
                        } else {
                            console.log("Checkpoint!");
                        }
                    });
                    debug("Received Result: ");
                    debug(result);
                }).catch(function(err) {
                    debug(err.message);
                });
            }
        },
        bindEvents: function() {
            UIController.init();
            UIController.attachPlayButtonClickListener(this.play);
            debug("User playing game..");

            App.contracts.RockPaperScissor.deployed().then(function(instance) {
                debug("RPS: Deployed instance recieved.");
                App.address.rps = instance.address;
                var temp = App.contracts.RockPaperScissor.at(instance.address);
                App.events.CheckPoint = temp.CheckPoint().watch(function(err, res){
                    console.log(res);
                });
                App.events.GameSessionCreated = temp.GameSessionCreated().watch(function(err, res){
                    console.log(res);
                });
                App.events.GameKeyReveal = temp.GameKeyReveal().watch(function(err, res){
                    console.log(res);
                });
                App.events.GameSessionEnded = temp.GameSessionEnded().watch(function(err, res){
                    console.log(res);
                });
                App.events.RevealValidTime = temp.RevealValidTime().watch(function(err, res){
                    console.log(res);
                });

                return true;
            }).catch(function(err) {
                debug(err.message);
            });
        },
    }
})()

$(window).on('load', function() {
    App.init();
});
