//
//  UserModeViewController.h
//  BluetoothServer
//
//  Created by Meritia on 08/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "ViewerModeViewController.h"
#import "PresentorModeViewController.h"

@interface UserModeViewController : UIViewController<GKSessionDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {
	GKSession *currentSession;
	UIAlertView *waitingAlert;
	UIActivityIndicatorView *activityIndicator;
	UIAlertView *progressAlert;
	UIProgressView *progressView;
	
	ViewerModeViewController *viewerModeVC;
	NSMutableData *fileData;
	int fileLength;
	int filePart;
	NSString *fileName;
	BOOL peerConnected;
	NSString* serverId;
}
@property (nonatomic, retain) GKSession *currentSession;
-(void) serverClicked;
-(void) clientClicked;
-(void) showPasswordSetter;
-(void) clean;
@end
