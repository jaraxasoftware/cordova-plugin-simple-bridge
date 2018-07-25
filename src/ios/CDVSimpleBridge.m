#import "CDVSimpleBridge.h"
#import "CDVSimpleBridgeViewController.h"

@interface CDVSimpleBridge ()
@property (assign, atomic) long callbackId;
@property (strong, nonatomic) NSMutableDictionary *callbacks;
@property (strong, nonatomic) NSString *mNativeToJsCallbackId;

@end

@implementation CDVSimpleBridge

- (long)getCallbackId
{
    return ++self.callbackId;
}

- (void)pluginInitialize
{
    if([self.viewController isKindOfClass:[CDVSimpleBridgeViewController class]]) {
        [(CDVSimpleBridgeViewController *)self.viewController setPlugin:self];
    }
}

- (void)init:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:YES];
    self.mNativeToJsCallbackId = command.callbackId;
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.mNativeToJsCallbackId];
}

- (void)executeNative:(CDVInvokedUrlCommand *)command
{
    NSString *methodName = [command.arguments objectAtIndex:0];
    NSArray *params = [command.arguments subarrayWithRange:NSMakeRange(1, [command.arguments count] - 1)];
    NativeMethod method = [self.mNativeMethods objectForKey:methodName];
    if (method) {
        CDVSimpleBridge * __weak weakSelf = self;
        method(params, ^(NSDictionary *result) {
            NSLog(@"Success");
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }, ^(NSDictionary *result) {
            NSLog(@"Error");
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        });
    }
}

- (NSString *)callJSMethod:(NSString *)aMethod withParams:(NSArray *)params completion:(MethodCallback)aBlock
{
    NSString *mTid = [NSString stringWithFormat:@"%@", @([self getCallbackId])];
    NSMutableArray *allArgs = [NSMutableArray array];
    [allArgs addObject:mTid];
    [allArgs addObject:aMethod];
    [allArgs addObjectsFromArray:params];
    [self.callbacks setObject:aBlock forKey:mTid];
    CDVPluginResult *dataResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:allArgs];
    [dataResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:dataResult callbackId:self.mNativeToJsCallbackId];
    return mTid;
}

- (void)methodCompleted:(CDVInvokedUrlCommand *)command
{
    NSString *callbackId = [command.arguments objectAtIndex:0];
    NSArray *params = [command.arguments subarrayWithRange:NSMakeRange(1, [command.arguments count] - 1)];
    CDVPluginResult* pluginResult;
    if(callbackId) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CordovaResponseNotification" object:self userInfo:@{@"callbackId": callbackId, @"params": params}];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)cordovaReady:(CDVInvokedUrlCommand *)command
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CordovaReadyNotification" object:self userInfo:@{}];
}

@end
