    //
//  LocalFileViewController.m
//  BluetoothServer
//
//  Created by Meritia on 25/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocalFileViewController.h"


@implementation LocalFileViewController

-(id) init
{
	NSFileManager* fileManager = [[NSFileManager new] autorelease];
	NSError *error;
	NSMutableArray *pdfs = [[[NSMutableArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:[DataWebLoader getDocumentsDirectoryPath] error:&error]] autorelease];
	
	for (int i = ([pdfs count] - 1); i >= 0 ; i--)
	{
		NSString *key = [pdfs objectAtIndex:i];
		if (!([key hasSuffix:@".pdf"]))
			[pdfs removeObjectAtIndex:i];
	}
	
	pdfPaths = [[[NSArray alloc] initWithArray:pdfs] retain];
	
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
	
	NSString *fileName = [[DataWebLoader getDocumentsDirectoryPath] stringByAppendingPathComponent:[pdfPaths objectAtIndex:(indexPath.row)]];
	
	DocPresentationViewController *controller = [[DocPresentationViewController alloc] initWithFilePath:fileName];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


@end
