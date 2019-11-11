App = {
  web3Provider: null,
  contracts: {},

  init: async function() {
    // Load pets.
    // console.log("HIHI");
    return await App.initWeb3();
  },

  initWeb3: async function() {
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.enable();
      } catch (error) {
        // User denied account access...
        console.error("User denied account access")
        console.log("error")
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function() {
    acc = web3.eth.accounts[0];
    $.get("http://localhost:8080", function(data){
      console.log(data);
    });
    $.getJSON('Basic.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var AdoptionArtifact = data;
      App.contracts.Basic = TruffleContract(AdoptionArtifact);
      console.log(App.contracts.Basic);
      
      // Set the provider for our contract
      App.contracts.Basic.setProvider(App.web3Provider);
    
      // Use our contract to retrieve and mark the adopted pets
      return App.markAdopted();
    });

    // return App.bindEvents();
  },

  bindEvents: function() {
    App.contracts.Basic.deployed().then(function(instance){
            con = instance;
            console.log(con.x);
    })
    console.log("enter bid events");
    $(document).on('click', '.one', App.handleAdopt);
    $(document).on('click', '.multi', App.handleAdopt1);

  },

  markAdopted: function(adopters, account) {
    console.log("mark adopted");
    App.contracts.Basic.deployed().then(function(instance){
      con = instance;
      console.log(con.x);
    });
  },

  handleAdopt: function(event) {
    event.preventDefault();
    // var basicInstance;
    var adoptionInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
    
      var account = accounts[0];
    
      App.contracts.Basic.deployed().then(function(instance) {
        adoptionInstance = instance;
        console.log(instance);
      
        // Execute adopt as a transaction by sending account
        return adoptionInstance.set(11);
      }).then(function(result) {
        console.log(result);
      }).catch(function(err) {
        console.log(err.message);
      });
    });
    // var petId = parseInt($(event.target).data('id'));
    // console.log(petId);

    /*
     * Replace me...
     */
  },
  handleAdopt1: function(event) {
    event.preventDefault();
    var basicInstance;
    App.contracts.Basic.deployed().then(function(instance){
      basicInstance = instance;
      return basicInstance.get();
    }).then(function(result){
      console.log(result);
    });
    // var petId = parseInt($(event.target).data('id'));
    // console.log(petId);

    /*
     * Replace me...
     */
  }

};

$(function() {
  // $(window).load(function() {
  //     App.init();
  // });
  $("#sign").click(function(event){
    event.preventDefault();
    App.init();
  });
  
});
