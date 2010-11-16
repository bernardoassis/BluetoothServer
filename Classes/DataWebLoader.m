//
//  Created by Björn Sållarp on 2008-09-03.
//  Copyright 2008 MightyLittle Industries. All rights reserved.
//
//  Read my blog @ http://jsus.is-a-geek.org/blog

#import "DataWebLoader.h"
#define NSURLResponseUnknownLength ((long long)-1)

@implementation DataWebLoader

@synthesize dataUrl, fileSize, workInProgress, tempFileName, finalFileName;

-(id) initWithUrl:(NSString*)url andDelegate:(id)new_delegate
{
	self = [super init];
	
	if(self)
	{
		self.dataUrl = url;
		[dataUrl retain];
		m_Delegate = new_delegate;
		[m_Delegate retain];
		dataLength = 0.0f;
	}
	
	return self;
}


- (void)setDelegate:(id)new_delegate
{
    m_Delegate = new_delegate;
}	

-(void)downloadData
{
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:dataUrl] 
											   cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
	dataConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if(dataConnection)
	{
		workInProgress = YES;
	}
}

-(void)abortDownload
{
	if(workInProgress)
		[self connection:dataConnection didFailWithError:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
	self.fileSize = [NSNumber numberWithLongLong:[response expectedContentLength]];
	
	NSString *file = nil;
	NSRange r = [(self.dataUrl) rangeOfString:@"/" options:NSBackwardsSearch];
	if (r.location != NSNotFound)
		file = [(self.dataUrl) substringFromIndex:(r.length + r.location)];
	else
		file = [NSString stringWithFormat:@"%.0f.pdf", 1000*[NSDate timeIntervalSinceReferenceDate]];
	
	self.tempFileName = [[NSTemporaryDirectory() stringByAppendingPathComponent:file] retain];
	self.finalFileName = [[[DataWebLoader getDocumentsDirectoryPath] stringByAppendingPathComponent:file] retain]; 
	
	NSFileManager* fileManager = [[NSFileManager new] autorelease];
	BOOL success = [fileManager createFileAtPath:(self.tempFileName) contents:nil attributes:nil];
	if (!success) {
		NSLog(@"DataWebLoader#connection:didReceiveData: Error creating file at path: %@", 
			  (self.tempFileName));
	}
	
	fileHandle = [[NSFileHandle fileHandleForWritingAtPath:(self.tempFileName)] retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
	
	@try {
		[fileHandle writeData:data];
	} @catch (NSException* e) {
		// In case we run out of disk space
		[self connection:connection didFailWithError:nil];
		return;
	}
	
	dataLength += [data length];
	
	if ([m_Delegate respondsToSelector:@selector(refreshLoadingView:)])
	{
		// Call the delegate method and pass ourselves along.
		NSNumber *concluded = [NSNumber numberWithFloat:(float)(dataLength / [self.fileSize floatValue])];
		[m_Delegate performSelectorOnMainThread:@selector(refreshLoadingView:) withObject:concluded waitUntilDone:NO];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the data object
	[dataConnection cancel];
	if (self.tempFileName) {
        NSFileManager* fileManager = [[NSFileManager new] autorelease];
        NSError* removeError;
        BOOL success = [fileManager removeItemAtPath:(self.tempFileName) error:&removeError];
        if (!success) {
            NSLog(@"DBRequest#connection:didFailWithError: error removing temporary file: %@", 
				  [removeError localizedDescription]);
        }
        [(self.tempFileName) release];
        self.tempFileName = nil;
    }
	
	dataLength = 0.0f;
	
    // inform the user
    if (error != nil)
		NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	workInProgress = NO;
	
	if ([m_Delegate respondsToSelector:@selector(dataReady:)])
	{
		// Call the delegate method and pass ourselves along.
		[m_Delegate dataReady:nil];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if ((workInProgress == YES) && ([self.fileSize longLongValue] != -1))
	{
		[fileHandle closeFile];
		[fileHandle release];
		fileHandle = nil;
		
		dataLength = 0.0f;
		
		workInProgress = NO;
		
		NSFileManager* fileManager = [[NSFileManager new] autorelease];
        NSError* moveError;
        BOOL success = [fileManager copyItemAtPath:(self.tempFileName) toPath:(self.finalFileName) error:&moveError];
        if (!success) {
            NSLog(@"DBRequest#connectionDidFinishLoading: error moving temp file to desired location: %@",
				  [moveError localizedDescription]);
        }

		// Verify that our delegate responds to the InternetImageReady method
		if ([m_Delegate respondsToSelector:@selector(dataReady:)])
		{
			// Call the delegate method and pass ourselves along.
			[m_Delegate dataReady:(self.finalFileName)];
		}
		
		[tempFileName release];
		self.tempFileName = nil;
	}
	else 
	{
		[self connection:connection didFailWithError:nil];
	}

}


- (void)dealloc 
{
    [dataConnection release];
	[dataUrl release];
	[super dealloc];
}

+(NSString*) getDocumentsDirectoryPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	return documentsDirectory;
}

@end
