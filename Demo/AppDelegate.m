//
//  AppDelegate.m
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 12/10/15.
//  Copyright © 2015 Matías Martínez. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ViewController *viewController = [[ViewController alloc] init];
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = viewController;
    
    self.window = window;
    
    [window makeKeyAndVisible];
    
    return YES;
}

@end
