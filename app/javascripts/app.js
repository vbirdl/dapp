// Import the page's CSS. Webpack will know what to do with it.
// import "../stylesheets/app.css";


// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import dmv_artifacts from '../../build/contracts/FloridaDepartmentOfMotorVehicles.json'

// MetaCoin is our usable abstraction, which we'll use through the code below.
var dmvContract = contract(dmv_artifacts);

// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.
var accounts;
var account;

window.App = {
  start: function() {
    var self = this;

    // Bootstrap the MetaCoin abstraction for Use.
    dmvContract.setProvider(web3.currentProvider);

    // Get the initial account balance so it can be displayed.
    web3.eth.getAccounts(function(err, accs) {
      if (err != null) {
        alert("There was an error fetching your accounts.");
        return;
      }

      if (accs.length == 0) {
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }

      accounts = accs;
      account = accounts[0];
    });
  },

  showAlert: function(message){
    console.log(message);
    sweetAlert("Oops...", message, "error");
  },
  showSuccess: function(message){
    swal("Success!", message, "success");
  },

  searchInsurance: function() {
    var self = this;
    var addr = $("#input_search_insurance").val();
    self.searchInsuranceByAddress(addr);
  },

  searchInsuranceByAddress: function(addr){
    var self = this;
    var dmv;

    dmvContract.deployed().then(function(instance) {
      dmv = instance;
      return dmv.IsApprovedInsurer.call(addr);

    }).then(function(value) {
      $("#box_insurance").fadeOut('slow', function() {
        $("#insurance_address").text(addr);
        if (value) {
          $("#insurance_validation").text("Valid");
        }else{
          $("#insurance_validation").text("Invalid");
        }
        $("#box_insurance").fadeIn();
      });
    }).catch(function(e) {
      self.showAlert(e);
    });
  },
  approveInsurance: function() {
    var self = this;
    var dmv;
    var addr = $("#insurance_address").text();

    dmvContract.deployed().then(function(instance) {
      dmv = instance;
      return dmv.ApproveInsurer(addr, {from:account});
    }).then(function() {
      self.searchInsuranceByAddress(addr);

    }).catch(function(e) {
      self.showAlert(e);
    });
  },
  revokeInsurance: function() {
    var self = this;
    var dmv;
    var addr = $("#insurance_address").text();

    dmvContract.deployed().then(function(instance) {
      dmv = instance;
      return dmv.DisapproveInsurer(addr, {from:account});
    }).then(function() {
      self.searchInsuranceByAddress(addr);

    }).catch(function(e) {
      self.showAlert(e);
    });
  },

  searchVehicleByPlate: function(plate){
    var self = this;
    var dmv;

    dmvContract.deployed().then(function(instance) {
      dmv = instance;      
      return dmv.QueryNumber.call(plate);
    }).then(function(value) {
        console.log(value);
        var sticker_date = new Date(value[2]*1000);
        var insurance_date = new Date(value[4]*1000);
        var date_now = new Date();

        console.log(sticker_date);
        console.log(insurance_date);

        $("#vehicle_plate").text(value[0]);
        $("#vehicle_vin").text(value[1]);
        $("#vehicle_sticker_date").text(sticker_date.toISOString().slice(0,10));
        $("#vehicle_insurance_addr").text(value[3]);
        $("#vehicle_insurance_date").text(insurance_date.toISOString().slice(0,10));

        $("#vehicle_insurance").text( insurance_date>date_now ? "Valid":"Invalid" );
        $("#vehicle_sticker").text( sticker_date>date_now ? "Valid":"Invalid" );
    }).catch(function(e) {
      self.showAlert(e);
    });
  },
  validateVehicleByPlate: function(plate){
    var self = this;
    var dmv;

    dmvContract.deployed().then(function(instance) {
      dmv = instance;
      return dmv.ValidatePlateNumber.call(plate);
    }).then(function(value) {
      $("#box_vehicle").fadeOut('slow', function() {
        $("#vehicle_plate").text(plate);
        $("#vehicle_vin").text("");
        $("#vehicle_addr").text("");
        $("#vehicle_insurance").text("");
        $("#vehicle_sticker").text("");

        if (value) {
          $("#vehicle_validation").text("Valid");
          self.searchVehicleByPlate(plate);
          $("#box_vehicle_info").show();
        }else{
          $("#vehicle_validation").text("Invalid");
          $("#box_vehicle_info").hide();
        }
        $("#box_vehicle").fadeIn();
      });
    }).catch(function(e) {
      self.showAlert(e);
    });
  },
  searchVehicle: function() {
    var self = this;
    var plate = $("#input_search_vehicle").val();
    self.validateVehicleByPlate(plate);
  },
  revokeVehicle: function() {
    var self = this;
    var dmv;
    var plate = $("#vehicle_plate").text();

    dmvContract.deployed().then(function(instance) {
      dmv = instance;
      return dmv.RevokePlate(plate, {from:account});
    }).then(function() {
      self.validateVehicleByPlate(plate);

    }).catch(function(e) {
      self.showAlert(e);
    });
  },

  addVehicle: function() {
    event.preventDefault();
    var self = this;
    var dmv;
    var plate = $("#input_add_vehicle_1").val();
    var vin = $("#input_add_vehicle_2").val();
    var sticker_date = new Date( $("#input_add_vehicle_3").val().replace( /(\d{2})-(\d{2})-(\d{4})/, "$2/$1/$3") );
    var insurance_date = new Date( $("#input_add_vehicle_4").val().replace( /(\d{2})-(\d{2})-(\d{4})/, "$2/$1/$3") );
    var insurance_addr = $("#input_add_vehicle_5").val();


    sticker_date = Math.floor(sticker_date / 1000);
    insurance_date = Math.floor(insurance_date / 1000);

    dmvContract.deployed().then(function(instance) {
      dmv = instance;
      return dmv.CreatePlate(plate,vin,sticker_date,insurance_addr,insurance_date, {from:account,gas:10000000});
    }).then(function() {
      self.showSuccess("Vehicle Added");
    }).catch(function(e) {
      self.showAlert(e);
    });
  }

};


window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  App.start();
});
