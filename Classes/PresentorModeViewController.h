//
//  PresentorModeViewController.h
//  BluetoothServer
//
//  Created by Meritia on 08/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropboxSDK.h"
#import "DropBoxFileViewController.h"
#import "LocalFileViewController.h"
#import "DataWebLoader.h"

@interface PresentorModeViewController : UIViewController<UIAlertViewDelegate, UINavigationControllerDelegate, DBSessionDelegate, DBLoginControllerDelegate> {
	UIAlertView *waitingAlert;
	UIProgressView *progressView;
	DataWebLoader *dataWebLoader;
}
@end
