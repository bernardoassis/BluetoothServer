//
//  BluetoothServerAppDelegate.h
//  BluetoothServer
//
//  Created by Meritia on 08/09/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModeViewController.h"

@interface BluetoothServerAppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabbarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabbarController;

@end

