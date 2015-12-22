(function () {

  'use strict';

  var Datastore = require('nedb');

  angular
    .module('app.invoice')
    .service('invoiceService', ['$rootScope', '$q', 'storageService', InvoiceService]);

  function InvoiceService($rootScope, $q, storageService) {

    // Create NeDB database containers
    //var invoiceStore = new Datastore({ filename: __dirname + '/data/accounting.db', autoload: true });
    var invoiceStore = new Datastore({ filename: storageService.getUserDataDirectory('accounting.db'), autoload: true });

    $rootScope.$on('backupRestored', function () {
      invoiceStore.loadDatabase();
    });

    return {
      getInvoices: getInvoices,
      createInvoice: createInvoice
    };

    function getInvoices() {
      var deferred = $q.defer();

      invoiceStore.find({}, function (err, docs) {
        if (err) deferred.reject(err);

        deferred.resolve(docs);
      });

      return deferred.promise;
    }

    function createInvoice(invoice) {
      var deferred = $q.defer();

      invoiceStore.insert(invoice, function (err, newDoc) {
        // newDoc is the newly inserted document, including its _id
        if (err) deferred.reject(err);

        deferred.resolve(newDoc);
      });

      return deferred.promise;
    }
  }
})();