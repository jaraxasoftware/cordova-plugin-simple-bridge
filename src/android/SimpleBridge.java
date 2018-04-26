package com.jaraxa.simplebridge;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import android.util.Log;

public class SimpleBridge extends CordovaPlugin {

	private static final String TAG = "SimpleBridge";

    /**
     * Constructor.
     */
    public SimpleBridge() {
		//TODO
    }

    /**
     * Sets the context of the Command. This can then be used to do things like
     * get file paths associated with the Activity.
     *
     * @param cordova The context of the main Activity.
     * @param webView The CordovaWebView Cordova is running in.
     */
    @SuppressWarnings("deprecation")
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
		//TODO
    }

    /**
     * Executes the request and returns PluginResult.
     *
     * @param action                The action to execute.
     * @param args          	    JSONArry of arguments for the plugin.
     * @param callbackS=Context     The callback id used when calling back into JavaScript.
     * @return              	    True if the action was valid.
     * @throws JSONException 
     */
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		Log.e(TAG, action + " args: " + args);
        if (action.equals("executeNative")) {
            //TODO
			PluginResult dataResult = new PluginResult(PluginResult.Status.OK);
			callbackContext.sendPluginResult(dataResult);			
        } else {
            // Unsupported action
            return false;
        }
        return true;
    }

}

