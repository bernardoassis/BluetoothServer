//
//  DropBoxFileViewController.h
//  BluetoothServer
//
//  Created by Meritia on 09/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DocPresentationViewController.h"
#import "DataDropboxLoader.h"

@interface DropBoxFileViewController : UIViewController<UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
	NSArray *pdfPaths;
	DataDropboxLoader *dataDropboxLoader;
	
	UITableView *tableView1;
	UIAlertView *waitingAlert;
	UIProgressView *progressView;
}
@property (nonatomic, retain) DataDropboxLoader *dataDropboxLoader;
-(void) displayError;
@end
