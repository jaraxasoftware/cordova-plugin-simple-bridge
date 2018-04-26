var exec = require("cordova/exec");

var simplebridge = {
	executeNative: function(successCallback, errorCallback, method, params) {
	    var newParams = params.slice();
	    newParams.unshift(method);		
		exec(successCallback, errorCallback, "SimpleBridge", "executeNative", newParams);
	}
};
module.exports = simplebridge;
