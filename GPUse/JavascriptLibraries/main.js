'use strict';

var bitcore = require('bitcore-lib');

global.BitcoreBridge = {
  createAddress: function() {
    var privateKey = new bitcore.PrivateKey();
    var address = privateKey.toAddress();
    return {"address": address.toString(), "privateKeyWIF": privateKey.toWIF()};
  }
}
