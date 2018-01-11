App = {
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
    $.getJSON('/RockPaperScissor.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract.
      var RockPaperScissorArtifact = data;
      App.contracts.RockPaperScissor = TruffleContract(RockPaperScissorArtifact);

      // Set the provider for our contract.
      App.contracts.RockPaperScissor.setProvider(App.web3Provider);

      return App.getTestNum();
    });

    return App.bindEvents();
  },

  bindEvents: function() {
      
  },
}

$(window).on('load', function() {
  App.init();
});
