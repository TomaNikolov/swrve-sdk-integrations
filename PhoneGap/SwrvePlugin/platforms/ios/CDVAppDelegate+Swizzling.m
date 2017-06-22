#import <objc/runtime.h>
#import "AppDelegate.h"
#import "Swrve.h"
#import "SwrvePlugin.h"

static void swizzleMethod(Class class, SEL destinationSelector, SEL sourceSelector);

@implementation CDVAppDelegate (Swrve)

+ (void)load {
    swizzleMethod([CDVAppDelegate class],
        @selector(application:didFinishLaunchingWithOptions:),
        @selector(my_application:didFinishLaunchingWithOptions:));

    swizzleMethod([CDVAppDelegate class],
        @selector(application:didReceiveRemoteNotification:),
        @selector(my_application:didReceiveRemoteNotification:));
}

- (BOOL)my_application: (UIApplication*)application
            didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    NSNumber *appId = NSBundle.mainBundle.infoDictionary[@"AppId"];
    NSString *apiKey = NSBundle.mainBundle.infoDictionary[@"ApiKey"];
    SwrveConfig* config = [[SwrveConfig alloc] init];
    [SwrvePlugin initWithAppID:[appId intValue]
                        apiKey:apiKey
                        config:config
                viewController:self.viewController
                launchOptions:launchOptions];

     return [self my_application:application didFinishLaunchingWithOptions:launchOptions];
}

-(void) my_application: (UIApplication*) application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [SwrvePlugin application:application didReceiveRemoteNotification:userInfo];
    [self my_application:application didReceiveRemoteNotification:userInfo];
}
@end

#pragma mark Swizzling

static void swizzleMethod(Class class, SEL destinationSelector, SEL sourceSelector) {
    Method destinationMethod = class_getInstanceMethod(class, destinationSelector);
    Method sourceMethod = class_getInstanceMethod(class, sourceSelector);

    // If the method doesn't exist, add it.  If it does exist, replace it with the given implementation.
    if (class_addMethod(class, destinationSelector, method_getImplementation(sourceMethod), method_getTypeEncoding(sourceMethod))) {
        class_replaceMethod(class, destinationSelector, method_getImplementation(destinationMethod), method_getTypeEncoding(destinationMethod));
    } else {
        method_exchangeImplementations(destinationMethod, sourceMethod);
    }
}
