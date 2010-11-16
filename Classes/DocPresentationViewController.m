    //
//  DocPresentationViewController.m
//  BluetoothServer
//
//  Created by Meritia on 08/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DocPresentationViewController.h"
#import "Utilities.h"

@implementation DocPresentationViewController

- (id)initWithFilePath:(NSString*) filePath {
    if (self = [super init]) {
		[[TVOutManager sharedInstance] startTVOut];
		NSURL *pdfURL = [NSURL fileURLWithPath:filePath];
		pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
		validatedSessions = [[NSMutableArray alloc] init];
		pdfData = [NSData dataWithContentsOfFile:filePath options:0 error:NULL];
		[pdfData retain];
    }
    return self;
}


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

- (void) viewWillAppear:(BOOL)animated 
{
	[self.navigationController setNavigationBarHidden:NO];
	self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
}

- (void)dealloc {
	CGPDFDocumentRelease(pdf);
    [super dealloc];
}

- (void) displayPageNumber:(NSUInteger)pageNumber {
	self.navigationItem.title = [NSString stringWithFormat:
								 @"%u of %u", 
								 pageNumber, 
								 CGPDFDocumentGetNumberOfPages(pdf)];
}

#pragma mark  LeavesViewDelegate methods

- (void) leavesView:(LeavesView *)leavesView willTurnToPageAtIndex:(NSUInteger)pageIndex {
	index = pageIndex;
	[self displayPageNumber:pageIndex + 1];
	
	NSString *strPage = [NSString stringWithFormat:@"P%i", pageIndex];
	NSData *data = [strPage dataUsingEncoding:NSUTF8StringEncoding];
	
	[self sendData:data ToPeer:nil];
}

#pragma mark LeavesViewDataSource methods

- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)leavesView {
	return CGPDFDocumentGetNumberOfPages(pdf);
}

- (void) renderPageAtIndex:(NSUInteger)idx inContext:(CGContextRef)ctx {
	CGPDFPageRef page = CGPDFDocumentGetPage(pdf, idx + 1);
	CGAffineTransform transform = aspectFit(CGPDFPageGetBoxRect(page, kCGPDFMediaBox),
											CGContextGetClipBoundingBox(ctx));
	CGContextConcatCTM(ctx, transform);
	CGContextDrawPDFPage(ctx, page);
}

#pragma mark UIViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Broadcast" style:UIBarButtonItemStylePlain target:self action:@selector(showPicker)] autorelease];
	//leavesView.backgroundRendering = YES;
	[self displayPageNumber:1];
	
	UIBarButtonItem *showBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Screenshots" style:UIBarButtonItemStyleBordered target:self action:@selector(showScreenshots)] autorelease];
	NSArray *items = [NSArray arrayWithObjects:showBtn, nil];
	
	CGRect appRect = [[UIScreen mainScreen] applicationFrame];
	uiToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, appRect.size.width, 30.0f)];
	uiToolbar.barStyle = UIBarStyleBlackTranslucent;
	uiToolbar.alpha = 0.50f;
	[uiToolbar setItems:items animated:NO];	
	[self.view addSubview:uiToolbar];
	
	[self mountScreenshotsBar];
}

#pragma mark GKPeerPickerControllerDelegate

-(void) showPicker
{	
	if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Broadcast"])
	{
		[self showPasswordSetter];
		currentSession = [[GKSession alloc] initWithSessionID:@"Grand" displayName:@"Grand Presentation" sessionMode:GKSessionModeServer];
		currentSession.delegate = self;
		[currentSession setDataReceiveHandler:self withContext:nil];
		currentSession.available = TRUE;	
		self.navigationItem.rightBarButtonItem.title = @"Stop";
	}
	else {
		currentSession.delegate = nil;
		[currentSession release];
		self.navigationItem.rightBarButtonItem.title = @"Broadcast";
	}
}


#pragma mark GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state)
    {
        case GKPeerStateConnected:
            NSLog(@"connected");
            break;
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
		//	session.delegate = nil;
		//	[sessions removeObjectForKey:peerID];
			break;
    }
}

-(void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
	
	// Request Received from peer. Please interpret and create a response for the peer.
	NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	if ([str hasPrefix:@"FILE"])
	{
		NSString *password = [str substringFromIndex:4];
		if ([(self->passwd) isEqualToString:password])
		{
			NSData *fileId = [[NSString stringWithFormat:@"F%i", [pdfData length]] dataUsingEncoding:NSUTF8StringEncoding];
			[self sendData:fileId ToPeer:peer];
		}
		else
		{
			NSData *fileId = [@"PASSWORD" dataUsingEncoding:NSUTF8StringEncoding];
			[self sendData:fileId ToPeer:peer];
		}
	}
	else
	{
		int part = [str intValue];
		if (((part +1) * 10000) > [pdfData length])
		{
			[self sendData:[pdfData subdataWithRange:NSMakeRange(part*10000, [pdfData length] - (part*10000))] ToPeer:peer];
			
			NSString *strPage = [NSString stringWithFormat:@"P%i", index];
			NSData *data = [strPage dataUsingEncoding:NSUTF8StringEncoding];
			
			[self sendData:data ToPeer:peer];
		}
		else
			[self sendData:[pdfData subdataWithRange:NSMakeRange(part*10000, 10000)] ToPeer:peer];
	}

}

- (void) sendData:(NSData *) data ToPeer:(NSString*) peerID
{
	if (peerID != nil)
		[currentSession sendData:data toPeers:[NSArray arrayWithObject:peerID] withDataMode:GKSendDataReliable error:nil];
	else
		[currentSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];

}

-(void) showPasswordSetter
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please set a Password for protect your presentation." message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	alert.tag = 999;
	[alert addTextFieldWithValue:@"" label:@"Password"];
	UITextField *textField = [alert textFieldAtIndex:0];
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.secureTextEntry = YES;
	
	alert.transform = CGAffineTransformTranslate( alert.transform, 0.0, 50.0 );
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 0)
	{
		if (alertView.tag == 999)
		{
			UITextField *urlTF = [alertView textFieldAtIndex:0];
			
			if ((urlTF.text != nil) && (![urlTF.text isEqualToString:@""]))
			{
				self->passwd = urlTF.text;
				[(self->passwd) retain];
				[alertView release];
			}
			else
			{
				[alertView release];
				
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The Password field was empty." message:@"Please set a password to continue your presentation." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				alert.tag = 1000;
				[alert show];
			}
		}
		else if (alertView.tag == 1000)
		{
			[alertView release];
			[self showPasswordSetter];
		}
	}
}

-(void) mountScreenshotsBar
{
	CGRect appRect = [[UIScreen mainScreen] applicationFrame];
	screenshotsView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -140.0f, appRect.size.width, 140.0f)];
	screenshotsView.backgroundColor = [UIColor grayColor];
	
	scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, appRect.size.width, 110.0f)];
	scrollView.backgroundColor = [UIColor clearColor];

	int pages = CGPDFDocumentGetNumberOfPages(pdf);
	
	for (int i = 0; i < pages; i++)
	{
		PDFExampleViewController *page = [[PDFExampleViewController alloc] initWithPDFFile:pdf andPage:i];
		page.view.frame = CGRectMake((i * (appRect.size.width / 3)) + 5.0f, 0.0f, 100.0f, 100.0f);
		page.view.tag = i;
		[scrollView addSubview:page.view];
	}
	scrollView.contentSize = CGSizeMake((pages * (appRect.size.width / 3)), 110.0f);
	
	[screenshotsView addSubview:scrollView];
	
	UIBarButtonItem *closeBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closeScreenshots)] autorelease];
	NSArray *items = [NSArray arrayWithObjects:closeBtn, nil];
	
	uiToolbarScreenshots = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 110.0f, appRect.size.width, 30.0f)];
	uiToolbarScreenshots.barStyle = UIBarStyleBlackTranslucent;
	[uiToolbarScreenshots setItems:items animated:NO];	
	[screenshotsView addSubview:uiToolbarScreenshots];
	
	[self.view addSubview:screenshotsView];
}

-(void) closeScreenshots
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5f];

	CGRect frame = screenshotsView.frame;
	frame.origin.y -= frame.size.height;
	screenshotsView.frame = frame;
	
	[UIView commitAnimations];
}

-(void) showScreenshots
{
	bugControl = YES;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5f];

	CGRect frame = screenshotsView.frame;
	frame.origin.y += frame.size.height;
	screenshotsView.frame = frame;
	
	[UIView commitAnimations];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation  duration:(NSTimeInterval)duration
{
	CGRect frame = screenshotsView.frame;
	frame.size.width = self.view.frame.size.width + self.view.frame.origin.x;
	screenshotsView.frame = frame;
	
	frame = uiToolbarScreenshots.frame;
	frame.size.width = self.view.frame.size.width + self.view.frame.origin.x;
	uiToolbarScreenshots.frame = frame;
	
	frame = uiToolbar.frame;
	frame.size.width = self.view.frame.size.width + self.view.frame.origin.x;
	uiToolbar.frame = frame;
	
	frame = scrollView.frame;
	frame.size.width = self.view.frame.size.width + self.view.frame.origin.x;
	scrollView.frame = frame;
	
	int i = 0;
	for (; i < [[scrollView subviews] count]; i++)
	{
		UIView *page = [[scrollView subviews] objectAtIndex:i];
		page.frame = CGRectMake((i * (frame.size.width / 3)), 0.0f, 100.0f, 100.0f);
	}
	if (bugControl)
		scrollView.contentSize = CGSizeMake(((i-2) * (frame.size.width / 3)), 110.0f);
	else
		scrollView.contentSize = CGSizeMake((i * (frame.size.width / 3)), 110.0f);

}

- (void)session:(GKSession *)sess didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	[sess acceptConnectionFromPeer:peerID error:nil];
}

- (void) clean
{
	currentSession.delegate = nil;
	[currentSession release];
}


@end
