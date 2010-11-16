//
//  Created by Björn Sållarp on 2008-09-03.
//  Copyright 2008 MightyLittle Industries. All rights reserved.
//
//  Read my blog @ http://jsus.is-a-geek.org

#import <Foundation/Foundation.h>

@interface DataWebLoader : NSObject {
	id m_Delegate;
	bool workInProgress;
	NSNumber *fileSize;
	
	NSURLConnection *dataConnection;
	NSString* dataUrl;
	
	NSString *tempFileName;
	NSString *finalFileName;
	NSFileHandle *fileHandle;
	
	float dataLength;
}


@property (nonatomic, retain) NSString* dataUrl;
@property (nonatomic, retain) NSString* tempFileName;
@property (nonatomic, retain) NSString* finalFileName;
@property (nonatomic, retain) NSNumber* fileSize;
@property (nonatomic, assign) bool workInProgress;

-(id)initWithUrl:(NSString*)url andDelegate:(id)new_delegate;
-(void)setDelegate:(id)new_delegate;
-(void)downloadData;
-(void)abortDownload;
+(NSString*) getDocumentsDirectoryPath;

@end


@interface NSObject (DataWebLoaderDelegate)
-(void) dataReady:(NSString*)fileName;
-(void) refreshLoadingView:(NSNumber*) concluded;
@end
