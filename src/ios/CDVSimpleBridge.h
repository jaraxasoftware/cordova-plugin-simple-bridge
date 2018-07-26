#import <Cordova/CDVPlugin.h>

typedef void(^JSMethodCallback)(NSArray *result);
typedef void(^MethodCallback)(NSDictionary *result);
typedef void(^NativeMethod)(NSArray *arguments, MethodCallback successCallback, MethodCallback errorCallback);

@interface CDVSimpleBridge : CDVPlugin

@property (strong, nonatomic) NSDictionary *mNativeMethods;

- (void)init:(CDVInvokedUrlCommand *)command;
- (void)executeNative:(CDVInvokedUrlCommand *)command;
- (void)callSuccess:(CDVInvokedUrlCommand *)command;
- (void)callError:(CDVInvokedUrlCommand *)command;
- (NSString *)callJSMethod:(NSString *)aMethod withParams:(NSArray *)params completion:(JSMethodCallback)aBlock;

@end
