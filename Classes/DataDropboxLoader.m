//
//  DataDropboxLoader.m
//  BluetoothServer
//
//  Created by Meritia on 24/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataDropboxLoader.h"


@implementation DataDropboxLoader
@synthesize restClient;

-(id) initWithDelegate:(id) delegate1
{
	delegate = delegate1;
	[delegate retain];
	[self restClient];
	[(self.restClient) loadMetadata:@"/" withHash:pdfHash];
	
	return self;
}

-(void) loadDataWithFile:(int) index
{
	NSString *file = nil;
	currentPdfPath = [pdfPaths objectAtIndex:index];
	NSRange r = [currentPdfPath rangeOfString:@"/" options:NSBackwardsSearch];
	if (r.location != NSNotFound)
		file = [currentPdfPath substringFromIndex:(r.length + r.location)];
	else
		file = [NSString stringWithFormat:@"%.0f", 1000*[NSDate timeIntervalSinceReferenceDate]];

	NSString *fileName = [[DataWebLoader getDocumentsDirectoryPath] stringByAppendingPathComponent:file];
	[self.restClient loadFile:currentPdfPath intoPath:fileName];
}

-(void) abortDownload
{
	[self.restClient cancelFileLoad:currentPdfPath];
}

#pragma mark DBRestClientDelegate methods

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    [pdfHash release];
    pdfHash = [metadata.hash retain];
    
    NSArray* validExtensions = [NSArray arrayWithObjects:@"pdf", nil];
    NSMutableArray* newPdfPaths = [NSMutableArray new];
    for (DBMetadata* child in metadata.contents) {
    	NSString* extension = [[child.path pathExtension] lowercaseString];
        if (!child.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) 
		{
            [newPdfPaths addObject:child.path];
        }
    }
    [pdfPaths release];
    pdfPaths = newPdfPaths;
	
    [delegate loadedMetadata:pdfPaths];
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
	[delegate loadedMetadata:pdfPaths];
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    NSLog(@"restClient:loadMetadataFailedWithError: %@", [error localizedDescription]);
    [delegate loadedMetadata:nil];
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
	[delegate dataReady:destPath];
	
}

- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath
{
	[delegate refreshLoadingView:[NSNumber numberWithFloat:progress]];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
	[delegate dataReady:nil];
}

- (DBRestClient*)restClient {
    if (restClient == nil) {
    	restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    	restClient.delegate = self;
    }
    return restClient;
}


@end
