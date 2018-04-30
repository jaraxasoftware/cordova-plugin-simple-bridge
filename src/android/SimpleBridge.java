package com.jaraxa.simplebridge;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public class SimpleBridge extends CordovaPlugin {

    public static final String INTENT_NAME = "SimpleBridgeInit";
	private static final String TAG = "SimpleBridge";
	private static Map<CordovaWebView, SimpleBridge> sInstances = new HashMap<CordovaWebView, SimpleBridge>();

	private CallbackContext mNativeToJsCallbackContext;
	private CordovaWebView mWebView;
	private AtomicInteger mTid;
	private Map<Integer,JsCallback> mSuccessCallbacks;
    private Map<Integer,JsCallback> mErrorCallbacks;
    private Map<String,NativeMethod> mNativeMethods;

    /**
     * Constructor.
     */
    public SimpleBridge() {
        mTid = new AtomicInteger(0);
        mSuccessCallbacks = new HashMap<Integer, JsCallback>();
        mErrorCallbacks = new HashMap<Integer, JsCallback>();
        mNativeMethods = new HashMap<String, NativeMethod>();
    }

    public Map<String, NativeMethod> getNativeMethods() {
        return mNativeMethods;
    }

    public void setNativeMethods(Map<String, NativeMethod> nativeMethods) {
        this.mNativeMethods = nativeMethods;
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
        mWebView = webView;
        sInstances.put(mWebView, this);
    }

    /**
     * Executes the request and returns PluginResult.
     *
     * @param action                The action to execute.
     * @param args          	    JSONArry of arguments for the plugin.
     * @param callbackContext       The callback id used when calling back into JavaScript.
     * @return              	    True if the action was valid.
     * @throws JSONException 
     */
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		Log.d(TAG, action + " args: " + args);
        if (action.equals("init")) {
            PluginResult dataResult = new PluginResult(PluginResult.Status.OK, new JSONArray());
            dataResult.setKeepCallback(true);
            mNativeToJsCallbackContext = callbackContext;
            mNativeToJsCallbackContext.sendPluginResult(dataResult);
            Intent intent = new Intent();
            intent.setAction(INTENT_NAME);
            LocalBroadcastManager.getInstance(mWebView.getContext()).sendBroadcast(intent);
        } else if (action.equals("executeNative")) {
            String methodName = args.getString(0);
            args.remove(0);
            NativeMethod method = mNativeMethods.get(methodName);
            if (method != null) {
                method.call(args, new JsCallback() {
                    @Override
                    public void done(JSONArray params) {
                        PluginResult dataResult = new PluginResult(PluginResult.Status.OK, params);
                        callbackContext.sendPluginResult(dataResult);
                    }
                }, new JsCallback() {
                    @Override
                    public void done(JSONArray params) {
                        PluginResult dataResult = new PluginResult(PluginResult.Status.ERROR, params);
                        callbackContext.sendPluginResult(dataResult);
                    }
                });
            }
        } else if (action.equals("callSuccess")) {
            Integer tid = args.getInt(0);
            args.remove(0);
            runSuccessCallback(tid, args);
            callbackContext.success();
        } else if (action.equals("callError")) {
            Integer tid = args.getInt(0);
            args.remove(0);
            runErrorCallback(tid, args);
            callbackContext.success();
        } else {
            // Unsupported action
            return false;
        }
        return true;
    }

    private void runSuccessCallback(Integer tid, JSONArray args) {
        JsCallback callback = mSuccessCallbacks.get(tid);
        clearCallbacks(tid);
        if (callback != null) {
            callback.done(args);
        }
    }

    private void runErrorCallback(Integer tid, JSONArray args) {
        JsCallback callback = mSuccessCallbacks.get(tid);
        clearCallbacks(tid);
        if (callback != null) {
            callback.done(args);
        }
    }

    private void clearCallbacks(Integer tid) {
        mSuccessCallbacks.remove(tid);
        mErrorCallbacks.remove(tid);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        sInstances.remove(mWebView);
    }

    public Integer callJS(String method, JSONArray args, JsCallback successCallback, JsCallback errorCallback) throws JSONException {
        Integer tid = mTid.addAndGet(1);
        Log.d(TAG, method + " tid: " + tid + " args: " + args);
        if (successCallback != null) {
            mSuccessCallbacks.put(tid, successCallback);
        }
        if (errorCallback != null) {
            mErrorCallbacks.put(tid, errorCallback);
        }
        JSONArray allArgs = new JSONArray();
        allArgs.put(tid);
        allArgs.put(method);
        for (int i = 0; i < args.length(); i++) {
            allArgs.put(args.get(i));
        }
        PluginResult dataResult = new PluginResult(PluginResult.Status.OK, allArgs);
        dataResult.setKeepCallback(true);
        mNativeToJsCallbackContext.sendPluginResult(dataResult);
        return tid;
    }

    public static SimpleBridge getInstance(CordovaWebView webView) {
        return sInstances.get(webView);
    }

    public static abstract class JsCallback {
        public abstract void done(JSONArray params);
    }

    public static abstract class NativeMethod {
        public abstract void call(JSONArray params, JsCallback successCallback, JsCallback errorCallback);
    }

}

