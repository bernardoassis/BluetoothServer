//
//  LocalFileViewController.h
//  BluetoothServer
//
//  Created by Meritia on 25/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataWebLoader.h"
#import "DocPresentationViewController.h"

@interface LocalFileViewController : UIViewController<UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
	NSArray *pdfPaths;
	UITableView *tableView1;
}

@end
