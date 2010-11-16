    //
//  DropBoxFileViewController.m
//  BluetoothServer
//
//  Created by Meritia on 09/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DropBoxFileViewController.h"


@implementation DropBoxFileViewController
@synthesize dataDropboxLoader;

-(id) init
{
	dataDropboxLoader = [[[DataDropboxLoader alloc] initWithDelegate:self] retain];
	
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
	
	tableView1 = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, appRect.size.width, appRect.size.height) style:UITableViewStylePlain];
	tableView1.backgroundColor = [UIColor colorWithRed:(239.0f/256.0f) green:(239.0f/256.0f) blue:(239.0f/256.0f) alpha:1.00f];
	tableView1.delegate = self;
	tableView1.dataSource = self;
 	[uiView addSubview:tableView1];
	
	self.view = uiView;
	[uiView release];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated 
{
	[self.navigationController setNavigationBarHidden:NO];
	self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	if (pdfPaths == nil)
		return 0;
	else
		return [pdfPaths count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSString *fileTitle = [pdfPaths objectAtIndex:indexPath.row];
	NSString *CellIdentifier = fileTitle;
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		CGRect CellFrame = CGRectMake(0, 0, 300, 40);
		CGRect Label1Frame = CGRectMake(10, 5, 280, 25);
		
		cell = [[[UITableViewCell alloc] initWithFrame:CellFrame reuseIdentifier:CellIdentifier] autorelease];
		
		//Initialize Label with tag 1.
		UILabel *lblTemp = [[UILabel alloc] initWithFrame:Label1Frame];
		lblTemp.textColor = [UIColor darkGrayColor];
		lblTemp.font = [UIFont boldSystemFontOfSize:16];
		lblTemp.tag = 1;
		lblTemp.backgroundColor = [UIColor clearColor];
		lblTemp.text = fileTitle;
		[cell.contentView addSubview:lblTemp];
		[lblTemp release];
	}
	
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 40;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath 
{
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	waitingAlert = [[UIAlertView alloc] initWithTitle:@"Loading file." message:@"Please wait...\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
	waitingAlert.tag = 999;
	progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
	progressView.frame = CGRectMake(80.0f, 80.0f, 120.0f, 20.0f);
	[progressView setProgress:0.0f];
	[waitingAlert addSubview:progressView];
	[waitingAlert show];
	
	[dataDropboxLoader loadDataWithFile:(indexPath.row)];
}

#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 0)
	{
		if (alertView.tag == 1000)
			[dataDropboxLoader abortDownload];
	}
	else
	{
		
	}
	
}

#pragma mark DataDropboxLoader methods

-(void) dataReady:(NSString *)fileName
{
	[waitingAlert dismissWithClickedButtonIndex:1 animated:YES];
	
	if (fileName != nil)
	{
		// Drawing a PDF page
		DocPresentationViewController *controller = [[DocPresentationViewController alloc] initWithFilePath:fileName];
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
	else
		[self displayError];
	
}

-(void) refreshLoadingView:(NSNumber*) concluded
{
	[progressView setProgress:[concluded floatValue]];
}

-(void) loadedMetadata:(NSArray*) metadata
{
	if (metadata != pdfPaths)
		pdfPaths = metadata;
    
	[tableView1 reloadData];
}

- (void)displayError {
    [[[[UIAlertView alloc] 
       initWithTitle:@"Error Loading File" message:@"There was an error loading your file." 
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
      autorelease]
     show];
}



@end
