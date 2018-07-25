#import <Cordova/CDVPlugin.h>

typedef void(^MethodCallback)(NSDictionary *);
typedef void(^NativeMethod)(NSArray *, MethodCallback, MethodCallback);

@interface CDVSimpleBridge : CDVPlugin

@property (strong, nonatomic) NSDictionary *mNativeMethods;

- (void)init:(CDVInvokedUrlCommand *)command;
- (void)executeNative:(CDVInvokedUrlCommand *)command;
- (void)methodCompleted:(CDVInvokedUrlCommand *)command;
- (void)cordovaReady:(CDVInvokedUrlCommand *)command;

@end
