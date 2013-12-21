//
//  PAAppDelegate.m
//  put.io adder
//
//  Created by Max Winde on 23.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

#import "PAPutIOController.h"

#import "PAAddTorrentViewController.h"
#import "PATransfersViewController.h"
#import "PAMainViewController.h"

#import "PAAppDelegate.h"

@interface PAAppDelegate ()

@end

@implementation PAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    PAMainViewController *controller = [[PAMainViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                       navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                     options:nil];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    self.window.tintColor = [UIColor colorWithRed:0.388 green:0.649 blue:0.109 alpha:1.000];
    
    self.navigationController = navigationController;
    self.window.rootViewController = navigationController;
    
    if ([PAPutIOController sharedController].putIOClient.ready == NO) {
        [self.navigationController presentViewController:[[PAPutIOController sharedController] authenticationViewController]
                                                animated:YES
                                              completion:nil];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
{
    if ([url.scheme isEqualToString:@"magnet"] || [url isFileURL]) {
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.navigationController presentViewController:[PAAddTorrentViewController addTorrentViewControllerWithTorrentURL:url]
                                                    animated:YES
                                                  completion:nil];
        });
        return YES;
    }
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}






@end
