App = {
  web3Provider: null,
  contracts: {},
  stemAddress: '0x353f7826be42a96292eee2b99c006a6c99364794',

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    // Initialize web3 and set the provider to the testRPC.
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // set the provider you want from Web3.providers
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
      web3 = new Web3(App.web3Provider);
    }

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('AutomiDemo.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract.
      var TutorialTokenArtifact = data;
      App.contracts.TutorialToken = TruffleContract(TutorialTokenArtifact);

      // Set the provider for our contract.
      App.contracts.TutorialToken.setProvider(App.web3Provider);

      // Use our contract to retieve and mark the adopted pets.
      return App.getBalances();
    });

    //return App.bindEvents();
  },

  belief: function(stemId) {
    var amount = 1;
    var toAddress = App.stemAddress;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.TutorialToken.deployed().then(function(instance) {
        tutorialTokenInstance = instance;

        console.log('Transferring 1 Lief Token from ' + account + ' to stem ID: ' + stemId + '(' + toAddress + ')');
        //return tutorialTokenInstance.transfer(toAddress, amount, {from: account});

        //return tutorialTokenInstance.createStem("rchain", "RChain");
        //return tutorialTokenInstance.createStem("goatse", "Goatse");
        //return tutorialTokenInstance.createStem("basicattention", "Basic Attention");
        return tutorialTokenInstance.stakeLief(stemId, 1);
        
      }).then(function(result) {
        alert('Transfer Successful!');
        App.getBalances();
        setTimeout(function() {
          window.location.reload();
        }, 500);
        return true;
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  // bindEvents: function() {
  //   $(document).on('click', '#transferButton', App.handleTransfer);
  // },

  // handleTransfer: function() {
  //   event.preventDefault();

  //   var amount = parseInt($('#TTTransferAmount').val());
  //   var toAddress = $('#TTTransferAddress').val();

  //   console.log('Transfer ' + amount + ' LF to ' + toAddress);

  //   var tutorialTokenInstance;

  //   web3.eth.getAccounts(function(error, accounts) {
  //     if (error) {
  //       console.log(error);
  //     }

  //     var account = accounts[0];

  //     App.contracts.TutorialToken.deployed().then(function(instance) {
  //       tutorialTokenInstance = instance;

  //       return tutorialTokenInstance.transfer(toAddress, amount, {from: account});
  //     }).then(function(result) {
  //       alert('Transfer Successful!');
  //       return App.getBalances();
  //     }).catch(function(err) {
  //       console.log(err.message);
  //     });
  //   });
  // },

  getBalances: function(adopters, account) {
    console.log('Getting balances...');

    var tutorialTokenInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.TutorialToken.deployed().then(function(instance) {
        tutorialTokenInstance = instance;

        tutorialTokenInstance.stems(1).then(function(data) {
          $('#data1').text(data[4].c[0]);
        });

        tutorialTokenInstance.stems(2).then(function(data) {
          $('#data2').text(data[4].c[0]);
        });

        tutorialTokenInstance.stems(3).then(function(data) {
          $('#data3').text(data[4].c[0]);
        });

        return tutorialTokenInstance.balanceOf(account);
      }).then(function(result) {
        console.log(result);
        balance = result.c[0];

        $('#myBalance').text(balance);
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },
};

$(function() {
  $(window).load(function() {
    App.init();
    window.app = App;
  });
});
