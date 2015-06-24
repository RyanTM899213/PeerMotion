//
//  AppDelegate.m
//  PeerMotion
//
//  Created by Ryan Martin on 2015-03-25.
//  Copyright (c) 2015 Ryan Martin. All rights reserved.
//

#import "AppDelegate.h"
#import "CMDisplayViewController.h"
#import "RemoteDisplayViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /*UIViewController *redVC = [[UIViewController alloc] init];
    redVC.view.backgroundColor = [UIColor redColor];
    redVC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:100];
    //redVC.tabBarItem.badgeValue = @"new!";
    */
    
    RemoteDisplayViewController *remote = [[RemoteDisplayViewController alloc] initWithNibName:@"CMDisplayViewController2" bundle:nil];
    remote.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Remote" image:[UIImage imageNamed:@"globe"] tag:100];
    
    CMDisplayViewController *local = [[CMDisplayViewController alloc] initWithNibName:@"CMDisplayViewController" bundle:nil];
    local.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Local" image:[UIImage imageNamed:@"house"] tag:101];
    
    //MCBrowserViewController *browserVC = [[MCBrowserViewController alloc] initWithServiceType:SERVICE_TYPE session:session];
    UIViewController *browserVC = [[UIViewController alloc] init];
    browserVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Connect" image:[UIImage imageNamed:@"Mobile_Signal"] tag:103];
    
    // create 3d rendering view controller here
    // threeD.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"3D Motion" image:[UIImage imageNamed:@"record"] tag:102];
    
    /*
    UIViewController *greenVC = [[UIViewController alloc] init];
    greenVC.view.backgroundColor = [UIColor greenColor];
    greenVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Players" image:[UIImage imageNamed:@"Players"] tag:101];
    */
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    UITabBarController *tbc = [[UITabBarController alloc] init];
    tbc.viewControllers = [NSArray arrayWithObjects: local, remote,/*threeD,  browserVC,*/ nil];
    
    self.window.rootViewController = tbc;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
