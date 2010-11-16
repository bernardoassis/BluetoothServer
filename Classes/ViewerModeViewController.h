//
//  ViewerModeViewController.h
//  BluetoothServer
//
//  Created by Meritia on 08/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeavesViewController.h"
#import "PDFScrollView.h"

@interface ViewerModeViewController : UIViewController<UINavigationControllerDelegate> {
	CGPDFDocumentRef pdf;
	PDFScrollView *pdfScrollView;
	NSString *filePath;
}
- (id)initWithFilePath:(NSString*) filePath1;
- (void) changePage:(int) page;
@end
