    //
//  ViewerModeViewController.m
//  BluetoothServer
//
//  Created by Meritia on 08/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ViewerModeViewController.h"
#import "Utilities.h"

@implementation ViewerModeViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


- (id)initWithFilePath:(NSString*) filePath1 {
    
	if (self = [super init]) {
		self->filePath = filePath1;
		[(self->filePath) retain];
    }
	
    return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	CGRect appRect = [[UIScreen mainScreen] applicationFrame];
	pdfScrollView = [[PDFScrollView alloc] initWithFrame:appRect andFilePath:(self->filePath)];
	[pdfScrollView retain];
	
	self.view = pdfScrollView;
}


- (void) viewWillAppear:(BOOL)animated 
{
	[self.navigationController setNavigationBarHidden:NO];
	self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	//return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	CGPDFDocumentRelease(pdf);
    [super dealloc];
}

- (void) displayPageNumber:(NSUInteger)pageNumber {
	self.navigationItem.title = [NSString stringWithFormat:
								 @"%u of %u", 
								 pageNumber, 
								 [(self->pdfScrollView) getPDFPages]];
}

/*
#pragma mark  LeavesViewDelegate methods

- (void) leavesView:(LeavesView *)leavesView willTurnToPageAtIndex:(NSUInteger)pageIndex {
	[self displayPageNumber:pageIndex + 1];
}

#pragma mark LeavesViewDataSource methods

- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)leavesView {
	return CGPDFDocumentGetNumberOfPages(pdf);
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
	CGPDFPageRef page = CGPDFDocumentGetPage(pdf, index + 1);
	CGAffineTransform transform = aspectFit(CGPDFPageGetBoxRect(page, kCGPDFMediaBox),
											CGContextGetClipBoundingBox(ctx));
	CGContextConcatCTM(ctx, transform);
	CGContextDrawPDFPage(ctx, page);
}
*/
#pragma mark UIViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	//leavesView.backgroundRendering = YES;
	[self displayPageNumber:0];
}

- (void) changePage:(int) page
{
	//[super setCurrentPageIndex:page];
	[(self->pdfScrollView) changePage:(page + 1)];
	[self displayPageNumber:(page + 1)];
}

@end
