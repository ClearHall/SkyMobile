#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Your application can present a full screen modal view controller to
    // cover its contents when it moves into the background. If your
    // application requires a password unlock when it retuns to the
    // foreground, present your lock screen or authentication view controller here.

    UIViewController *blankViewController = [UIViewController new];
    blankViewController.view.backgroundColor = [UIColor blackColor];

    // Pass NO for the animated parameter. Any animation will not complete
    // before the snapshot is taken.
    [self.window.rootViewController presentViewController:blankViewController animated:NO completion:NULL];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // This should be omitted if your application presented a lock screen
    // in -applicationDidEnterBackground:
    [self.window.rootViewController dismissViewControllerAnimated:NO completion:NULL];
}

@end
