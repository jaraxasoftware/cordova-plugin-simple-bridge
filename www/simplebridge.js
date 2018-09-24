var exec = require("cordova/exec"),
    channel = require('cordova/channel');

var simplebridge = (function () {
    var _exportedApi;

    channel.onCordovaReady.subscribe(function() {
        var successCallback = function(params) {
            console.log("SimpleBridge from native ", params);
            if (params.length >= 2) {
                var tid = params[0];
                var method = params[1];
                var restParams = params.slice(2);
                if (typeof(_exportedApi[method]) !== "undefined") {
                    _exportedApi[method](function(){
                        var newParams = Array.prototype.slice.call(arguments);
                        newParams.unshift(tid);
                        exec(null, null, 'SimpleBridge', 'callSuccess', newParams);
                    },function(){
                        var newParams = Array.prototype.slice.call(arguments);
                        newParams.unshift(tid);
                        exec(null, null, 'SimpleBridge', 'callError', newParams);
                    }, restParams);
                }
            } else {
                console.log("SimpleBridge init");
            }
        };
        var errorCallback = function(params) {
            console.log("SimpleBridge from native (ERROR) ", params);
        };
        exec(successCallback, errorCallback, 'SimpleBridge', 'init', []);
    });

    return {
        executeNative: function(successCallback, errorCallback, method, params) {
            var newParams = params.slice();
            newParams.unshift(method);
            exec(successCallback, errorCallback, "SimpleBridge", "executeNative", newParams);
        },
        exportApi: function(api) {
            _exportedApi = api;
        }
    };
})();

module.exports = simplebridge;
