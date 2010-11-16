    //
//  PresentorModeViewController.m
//  BluetoothServer
//
//  Created by Meritia on 08/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PresentorModeViewController.h"
#define CONSUMER_KEY @"j3qm4wetyng93r1"
#define SECRET_KEY @"2h8fg51medtf1vw"

@implementation PresentorModeViewController

-(id) init
{
	DBSession* dbSession = [[[DBSession alloc] initWithConsumerKey:CONSUMER_KEY consumerSecret:SECRET_KEY] autorelease];
	dbSession.delegate = self;
	[DBSession setSharedSession:dbSession];

	return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	
	CGRect appRect = [[UIScreen mainScreen] applicationFrame];
	UIView *uiView = [[UIView alloc] initWithFrame:appRect];
	uiView.autoresizesSubviews = YES; 
	uiView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	uiView.backgroundColor = [UIColor whiteColor];
	
	UIImage *bgImg = [UIImage imageNamed:@"Default.png"];
	UIImageView *bgImgView = [[UIImageView alloc] initWithImage:bgImg];
	bgImgView.frame = CGRectMake(0.0f, -64.0f, bgImg.size.width, bgImg.size.height);
	[uiView addSubview:bgImgView];
	[bgImgView release];
	
	UIImage *dropBoxImg = [UIImage imageNamed:@"dropbox.png"];
	UIButton *dropBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[dropBoxBtn setImage:dropBoxImg forState:UIControlStateNormal];
	dropBoxBtn.tag = 0;
	dropBoxBtn.frame = CGRectMake((appRect.size.width - dropBoxImg.size.width)/2, 275.0f, dropBoxImg.size.width, dropBoxImg.size.height);
	dropBoxBtn.backgroundColor = [UIColor clearColor];
	[dropBoxBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[uiView addSubview:dropBoxBtn];
	
	UIImage *webImg = [UIImage imageNamed:@"web.png"];
	UIButton *webBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[webBtn setImage:webImg forState:UIControlStateNormal];
	webBtn.tag = 1;
	webBtn.frame = CGRectMake((appRect.size.width - webImg.size.width)/2, 320.0f, webImg.size.width, webImg.size.height);
	webBtn.backgroundColor = [UIColor clearColor];
	[webBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[uiView addSubview:webBtn];
	
	UIImage *localImg = [UIImage imageNamed:@"local.png"];
	UIButton *localBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[localBtn setImage:localImg forState:UIControlStateNormal];
	localBtn.tag = 2;
	localBtn.frame = CGRectMake((appRect.size.width - localImg.size.width)/2, 365.0f, localImg.size.width, localImg.size.height);
	localBtn.backgroundColor = [UIColor clearColor];
	[localBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[uiView addSubview:localBtn];
		
	self.view = uiView;
	[uiView release];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) viewWillAppear:(BOOL)animated 
{
	[self.navigationController setNavigationBarHidden:NO];
	self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
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
    [super dealloc];
}

-(void) buttonClicked:(id) sender
{
	int tag = [sender tag];
	
	if (tag == 0)
	{
		// DropBox
		DBLoginController* controller = [[DBLoginController new] autorelease];
		controller.delegate = self;
		[controller presentFromController:self];
	}
	else if (tag == 1)
	{
		// Web
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter with the file URL." message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
		alert.tag = 999;
		[alert addTextFieldWithValue:@"http://" label:@"URL"];
		UITextField *textField = [alert textFieldAtIndex:0];
		textField.autocorrectionType = UITextAutocorrectionTypeNo;
		textField.keyboardType = UIKeyboardTypeURL;
		
		alert.transform = CGAffineTransformTranslate( alert.transform, 0.0, 50.0 );
		[alert show];
	}
	else if (tag == 2)
	{
		// Local
		LocalFileViewController *localFileVC = [[LocalFileViewController alloc] init];
		localFileVC.title = @"Local File Database";
		[self.navigationController pushViewController:localFileVC animated:YES];
		[localFileVC release];
	}
}

#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session {
	DBLoginController* loginController = [[DBLoginController new] autorelease];
	[loginController presentFromController:self];
}

#pragma mark DBLoginControllerDelegate methods

- (void)loginControllerDidLogin:(DBLoginController*)controller {
    DropBoxFileViewController *dropBoxFileVC = [[DropBoxFileViewController alloc] init];
	dropBoxFileVC.title = @"DropBox File Server";
	[self.navigationController pushViewController:dropBoxFileVC animated:YES];
	[dropBoxFileVC release];
}

- (void)loginControllerDidCancel:(DBLoginController*)controller {
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex > 0)
	{
		if (alertView.tag == 999)
		{
			UITextField *urlTF = [alertView textFieldAtIndex:0];
			NSString *url = urlTF.text;
			
			[alertView release];
			
			waitingAlert = [[UIAlertView alloc] initWithTitle:@"Loading file." message:@"Please wait...\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
			waitingAlert.tag = 1000;
			progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
			progressView.frame = CGRectMake(80.0f, 80.0f, 120.0f, 20.0f);
			[progressView setProgress:0.0f];
			[waitingAlert addSubview:progressView];
			[waitingAlert show];
			
			dataWebLoader = [[[DataWebLoader alloc] initWithUrl:url andDelegate:self] retain];
			[dataWebLoader downloadData];
		}
	}
	else
	{
		if (alertView.tag == 1000)
			[dataWebLoader abortDownload];
	}

}

#pragma mark DataWebLoaderDelegate methods

- (void)dataReady:(NSString*)fileName
{
	[waitingAlert dismissWithClickedButtonIndex:0 animated:YES];
	[waitingAlert release];
	
	if (fileName == nil)
	{
		[[[[UIAlertView alloc] 
		   initWithTitle:@"Error Loading File" message:@"There was an error loading your file." 
		   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
		  autorelease]
		 show];
	}
	else
	{
		DocPresentationViewController *controller = [[DocPresentationViewController alloc] initWithFilePath:fileName];
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
}

-(void) refreshLoadingView:(NSNumber*) concluded
{
	[progressView setProgress:[concluded floatValue]];
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([viewController isKindOfClass:[DocPresentationViewController class]])
		[(DocPresentationViewController*)viewController clean];
}

@end
