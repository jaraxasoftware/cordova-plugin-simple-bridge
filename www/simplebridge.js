var exec = require("cordova/exec");

var simplebridge = {
	executeNative: function(successCallback, errorCallback, method, params) {
		exec(successCallback, errorCallback, "SimpleBridge", "executeNative", params.slice().unshift(method));
	}
};
module.exports = simplebridge;
