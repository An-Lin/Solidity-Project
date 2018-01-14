var App = (function() {
    var UIController = (function() {
        const MINIMUM_PASSWORD_LENGTH = 3; // CHANGE FOR PRODUCTION
        const MINIMUM_USERNAME_LENGTH = 3; // CHANGE FOR PRODUCTION
        var bet_amount = '0.1'; // CHANGE FOR PRODUCTION
        var $nonce = $("#nonce");
        var $username = $("#username");
        var $playButton = $("#play-button");

        function attachUIListeners() {

        }

        return {
            init: function() {
                attachUIListeners();
                this.clear();
            },
            clear: function() {
                $nonce.val("");
            },
            validPassword: function(){
                var result = $nonce.val().length >= MINIMUM_PASSWORD_LENGTH;
                if (result) {
                    return true;
                }
                alert("Please choose a password!");
                return false;
            },
            getPassword: function(){
                return $nonce.val();
            },
            validUsername: function(){
                var result = $username.val().length >= MINIMUM_USERNAME_LENGTH;
                if (result) {
                    return true;
                }
                alert("Please choose a username!");
                return false;
            },
            getUsername: function(){
                return $username.val();
            },
            getAmount: function(){
                return bet_amount;
            },
            userCanPlay: function() {
                return this.validPassword() && this.validUsername();
            },
            attachPlayButtonClickListener: function(func){
                $playButton.click(func);
            }
        }
    })()

    var Events = (function(){
        var checkpoint;

        return {
            init: function(){
                // checkpoint = App.contracts.CheckPoint(function(err, result){
                //     console.log(result);
                // });
            }

        }
    })();

    return {
        web3Provider: null,
        contracts: {},

        init: function() {
            console.log("Initializing Web App.");
            return App.initWeb3();
        },
        initWeb3: function() {
            console.log("Connecting to Web3 Provider..");
            // Initialize web3 and set the provider
            HelperUtil.initWeb3(App);
            return App.initContract();
        },

        initContract: function() {
            console.log("Instantiating Smart Contract Artifact...");
            $.getJSON('/web/contracts/RockPaperScissor.json', function(data) {
                // Get the necessary contract artifact file and instantiate it with truffle-contract.
                var RockPaperScissorArtifact = data;
                App.contracts.RockPaperScissor = TruffleContract(RockPaperScissorArtifact);

                // Set the provider for our contract.
                App.contracts.RockPaperScissor.setProvider(App.web3Provider);
                return true;
            });

            return App.bindEvents();
        },
        play: function(){
            if (UIController.userCanPlay()) {
                //AJAX call
                console.log("User playing game..");

                var RockPaperScissorInstance;

                App.contracts.RockPaperScissor.deployed().then(function(instance) {
                    RockPaperScissorInstance = instance;
                    pass = web3.sha3(UIController.getPassword());
                    user = UIController.getUsername();
                    amount = new BigNumber(web3.toWei(UIController.getAmount(), 'ether'));
                    console.log(pass, user, amount);
                    return RockPaperScissorInstance.play(pass, user, {from: web3.eth.accounts[0], value: amount});
                }).then(function(result) {
                    console.log(result);
                    num = result.c[0];
                }).catch(function(err) {
                    console.log(err.message);
                });
            }
        },
        bindEvents: function() {
            Events.init();
            UIController.init();
            UIController.attachPlayButtonClickListener(this.play);
        },
    }
})()

$(window).on('load', function() {
    App.init();
});
