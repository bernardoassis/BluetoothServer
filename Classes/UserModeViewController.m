    //
//  UserModeViewController.m
//  BluetoothServer
//
//  Created by Meritia on 08/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserModeViewController.h"

@implementation UserModeViewController
@synthesize currentSession;


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	CGRect appRect = [[UIScreen mainScreen] applicationFrame];
	UIView *uiView = [[UIView alloc] initWithFrame:appRect];
	uiView.autoresizesSubviews = YES; 
	uiView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	uiView.backgroundColor = [UIColor whiteColor];
	
	UIImage *bgImg = [UIImage imageNamed:@"Default.png"];
	UIImageView *bgImgView = [[UIImageView alloc] initWithImage:bgImg];
	bgImgView.frame = CGRectMake((appRect.size.width - bgImg.size.width)/2, -20.0f, bgImg.size.width, bgImg.size.height);
	[uiView addSubview:bgImgView];
	[bgImgView release];
	
	UIImage *serverBtnImg = [UIImage imageNamed:@"give_presentation.png"];
	UIButton *serverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[serverBtn setImage:serverBtnImg forState:UIControlStateNormal];
	serverBtn.frame = CGRectMake((uiView.frame.size.width - serverBtnImg.size.width)/2, 330.0f, serverBtnImg.size.width, serverBtnImg.size.height);
	serverBtn.backgroundColor = [UIColor clearColor];
	[serverBtn addTarget:self action:@selector(serverClicked) forControlEvents:UIControlEventTouchUpInside];
	[uiView addSubview:serverBtn];
	
	UIImage *clientBtnImg = [UIImage imageNamed:@"view_presentation.png"];
	UIButton *clientBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[clientBtn setImage:clientBtnImg forState:UIControlStateNormal];
	clientBtn.frame = CGRectMake((uiView.frame.size.width - clientBtnImg.size.width)/2, 380.0f, clientBtnImg.size.width, clientBtnImg.size.height);
	clientBtn.backgroundColor = [UIColor clearColor];
	[clientBtn addTarget:self action:@selector(clientClicked) forControlEvents:UIControlEventTouchUpInside];
	[uiView addSubview:clientBtn];

	self.view = uiView;
	[uiView release];
}

- (void) viewWillAppear:(BOOL)animated 
{
	[self.navigationController setNavigationBarHidden:YES];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

-(void) serverClicked
{	
	PresentorModeViewController *presentorVC = [[PresentorModeViewController alloc] init];
	presentorVC.title = @"Find your Presentation";
	[self.navigationController pushViewController:presentorVC animated:YES];
	[presentorVC release];
}

-(void) clientClicked
{
    currentSession = [[GKSession alloc] initWithSessionID:@"Grand" displayName:@"Grand Presentation" sessionMode:GKSessionModeClient];
	currentSession.delegate = self;
    [currentSession setDataReceiveHandler:self withContext:nil];
	currentSession.available = TRUE;
		
	self->waitingAlert = [[UIAlertView alloc] initWithTitle:@"Searching for presentations." message:@"Please wait...\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
	self->waitingAlert.tag = 1001;
	self->activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	(self->activityIndicator).frame = CGRectMake(124.5f, 69.0f, 30.0f, 30.0f);
	(self->activityIndicator).hidesWhenStopped = YES;
	[(self->waitingAlert) addSubview:(self->activityIndicator)];
	[(self->activityIndicator) startAnimating];
	[(self->waitingAlert) show];
}

- (void) sendData:(NSData *) data
{
	[currentSession sendData:data toPeers:[NSArray arrayWithObject:serverId] withDataMode:GKSendDataReliable error:nil];
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
	NSString *idComm = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	if ([idComm hasPrefix:@"F"])
	{
		fileData = [[[NSMutableData alloc] init] retain];
		fileLength = [[idComm substringFromIndex:1] intValue];
		[self sendData:[@"0" dataUsingEncoding:NSUTF8StringEncoding]];
		filePart = 1;
	}
	else if ([idComm isEqualToString:@"PASSWORD"])
	{
		[(self->waitingAlert) dismissWithClickedButtonIndex:1 animated:TRUE];
		[self showPasswordSetter];
	}
	else if ([idComm hasPrefix:@"P"])
	{
		if (viewerModeVC != nil)
			[viewerModeVC changePage:[[idComm substringFromIndex:1] intValue]];
	}
	else
	{
		// incrementando o byte array do pdf.
		[fileData appendData:data];
		[self refreshLoadingView:[NSNumber numberWithFloat:(float)((float)[fileData length]/(float)fileLength)]];
		
		if ([fileData length] == fileLength)
		{
			fileLength = 0;
			
			fileName = [NSString stringWithFormat:@"%.0f", 1000*[NSDate timeIntervalSinceReferenceDate]];
			fileName = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
			[fileName retain];
			
			NSFileManager* fileManager = [[NSFileManager new] autorelease];
			BOOL success = [fileManager createFileAtPath:fileName contents:fileData attributes:nil];
			if (!success)
				NSLog(@"DataWebLoader#connection:didReceiveData: Error creating file at path: %@", fileName);
			
			viewerModeVC = [[[ViewerModeViewController alloc] initWithFilePath:fileName] retain];
			
			[(self->waitingAlert) dismissWithClickedButtonIndex:1 animated:TRUE];
			[(self->waitingAlert) release];
			
			[self.navigationController pushViewController:viewerModeVC animated:YES];
		}
		else
		{
			NSString *part = [NSString stringWithFormat:@"%i", filePart];
			filePart += 1;
			[self sendData:[part dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	
    if (state == GKPeerStateConnected)
	{
		if (!peerConnected)
		{
			NSLog(@"connected");
			peerConnected = YES;
			(self->waitingAlert).tag = 1000;
			[(self->waitingAlert) dismissWithClickedButtonIndex:1 animated:TRUE];

			//connected
			if (fileName == nil)
				[self sendData:[@"FILE" dataUsingEncoding:NSUTF8StringEncoding]];
			else
			{
				[(self->waitingAlert) release];
				viewerModeVC = [[[ViewerModeViewController alloc] initWithFilePath:fileName] retain];
				[self.navigationController pushViewController:viewerModeVC animated:YES];
			}
		}
	}
	else if (state == GKPeerStateDisconnected) {
		[self.navigationController popViewControllerAnimated:YES];
		[self clientClicked];
	}
	else if (state == GKPeerStateAvailable)
	{
		NSArray* arr = [session peersWithConnectionState:GKPeerStateAvailable];

		if (!peerConnected)
		{
			if ([arr count] > 0)
			{
				[session connectToPeer:[arr objectAtIndex:0] withTimeout:30];	
				serverId = [arr objectAtIndex:0];
				[serverId retain];
			}
		}
		else 
		{
			for (NSString *peer in arr)
			{
				if ([peer isEqualToString:serverId])
				{
					[session connectToPeer:peer withTimeout:30];	
					break;
				}
			}
		}
	}
}

-(void) showPasswordSetter
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please type a Password for access this presentation." message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
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
			if (peerConnected)
			{
				UITextField *urlTF = [alertView textFieldAtIndex:0];
				
				if ((urlTF.text != nil) && (![urlTF.text isEqualToString:@""]))
				{
					[self sendData:[[NSString stringWithFormat:@"FILE%@", urlTF.text] dataUsingEncoding:NSUTF8StringEncoding]];
					[alertView release];
					
					self->waitingAlert = [[UIAlertView alloc] initWithTitle:@"Receiving server Presentation." message:@"Please wait...\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
					self->waitingAlert.tag = 1000;
					progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
					progressView.frame = CGRectMake(80.0f, 90.0f, 120.0f, 20.0f);
					[progressView setProgress:0.0f];
					[self->waitingAlert addSubview:progressView];
					[self->waitingAlert show];
				}
				else
				{
					[alertView release];
					
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The Password field was empty." message:@"Please enter a password to view this presentation." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
					alert.tag = 1000;
					[alert show];
				}
			}
			else 
			{
				[alertView release];
				
				//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your peer closed the connection." message:@"Please make a new connection." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				//alert.tag = 1001;
				//[alert show];
			}

		}
		else if (alertView.tag == 1000)
		{
			[alertView release];
			[self showPasswordSetter];
		}
		else if (alertView.tag == 1001)
		{
			[alertView release];
			self->currentSession = nil;
			self->peerConnected = NO;
		}
	}
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	[self clean];
}

-(void) clean
{
	peerConnected = NO;
	[currentSession release];
	currentSession = nil;
}

-(void) refreshLoadingView:(NSNumber*) concluded
{
	[progressView setProgress:[concluded floatValue]];
}

@end
