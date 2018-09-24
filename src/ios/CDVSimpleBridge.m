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

- (NSMutableDictionary *)callbacks
{
    if(!_callbacks) {
        _callbacks = [[NSMutableDictionary alloc] init];
    }
    return _callbacks;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SimpleBridgeInit" object:self userInfo:@{}];
}

- (void)executeNative:(CDVInvokedUrlCommand *)command
{
    NSString *methodName = [command.arguments objectAtIndex:0];
    NSArray *params = [command.arguments subarrayWithRange:NSMakeRange(1, [command.arguments count] - 1)];
    NativeMethod method = [self.mNativeMethods objectForKey:methodName];
    if (method) {
        CDVSimpleBridge * __weak weakSelf = self;
        method(params, ^(NSArray *result) {
            NSLog(@"Success");
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:result];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }, ^(NSArray *result) {
            NSLog(@"Error");
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsArray:result];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        });
    }
}

- (void)callSuccess:(CDVInvokedUrlCommand *)command
{
    NSString *mTid = [command.arguments objectAtIndex:0];
    NSArray *params = [command.arguments subarrayWithRange:NSMakeRange(1, [command.arguments count] - 1)];
    params = [@[@(YES)] arrayByAddingObjectsFromArray:params];
    JSMethodCallback callback = [self.callbacks objectForKey:mTid];
    [self.callbacks removeObjectForKey:mTid];
    if(callback) {
        callback(params);
    }
}

- (void)callError:(CDVInvokedUrlCommand *)command
{
    NSString *mTid = [command.arguments objectAtIndex:0];
    NSArray *params = [command.arguments subarrayWithRange:NSMakeRange(1, [command.arguments count] - 1)];
    params = [@[@(NO)] arrayByAddingObjectsFromArray:params];
    JSMethodCallback callback = [self.callbacks objectForKey:mTid];
    [self.callbacks removeObjectForKey:mTid];
    if(callback) {
        callback(params);
    }
}

- (NSString *)callJSMethod:(NSString *)aMethod withParams:(NSArray *)params completion:(JSMethodCallback)aBlock
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

@end
