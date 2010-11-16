//
//  DocPresentationViewController.h
//  BluetoothServer
//
//  Created by Meritia on 08/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "LeavesViewController.h"
#import "PDFExampleViewController.h"
#import "TVOutManager.h"

@interface DocPresentationViewController : LeavesViewController<GKSessionDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {
	GKSession* currentSession;
	NSMutableArray* validatedSessions;
	
	CGPDFDocumentRef pdf;
	NSMutableData *pdfData;
	NSString *passwd;
	
	UIView *screenshotsView;
	UIToolbar *uiToolbar;
	UIToolbar *uiToolbarScreenshots;
	UIScrollView *scrollView;
	
	BOOL bugControl;
	
	int index;
}
- (id)initWithFilePath:(NSString*) filePath;
- (void) sendData:(NSData *) data ToPeer:(NSString*) peerId;
- (void) showPasswordSetter;
- (void) mountScreenshotsBar;
- (void) showScreenshots;
- (void) closeScreenshots;
- (void) clean;

@end

