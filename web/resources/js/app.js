var App = (function() {
    var UIController = (function() {
        const MINIMUM_PASSWORD_LENGTH = 3; // CHANGE FOR PRODUCTION
        const MINIMUM_USERNAME_LENGTH = 3; // CHANGE FOR PRODUCTION
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
                var result = $nonce.val().length > MINIMUM_PASSWORD_LENGTH;
                if (result) {
                    return true;
                }
                alert("Please choose a password!");
                return false;
            },
            validUsername: function(){
                var result = $username.val().length > MINIMUM_USERNAME_LENGTH;
                if (result) {
                    return true;
                }
                alert("Please choose a username!");
                return false;
            },
            userCanPlay: function() {
                return this.validPassword() && this.validUsername();
            },
            attachPlayButtonClickListener: function(func){
                $playButton.click(func);
            }
        }
    })()

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

                    return RockPaperScissorInstance.play();
                }).then(function(result) {
                    num = result.c[0];
                }).catch(function(err) {
                    console.log(err.message);
                });
            }
        },
        bindEvents: function() {
            UIController.init();
            UIController.attachPlayButtonClickListener(this.play());
        },
    }
})()

$(window).on('load', function() {
    App.init();
});
