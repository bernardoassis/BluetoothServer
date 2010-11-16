//
//  DataDropboxLoader.h
//  BluetoothServer
//
//  Created by Meritia on 24/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DropboxSDK.h"
#import "DataWebLoader.h"

@interface DataDropboxLoader : NSObject<DBRestClientDelegate> {
	DBRestClient* restClient;
	NSArray* pdfPaths;
    NSString* pdfHash;
    NSString* currentPdfPath;
	id delegate;
}
@property (nonatomic, retain) DBRestClient* restClient;

-(id) initWithDelegate:(id) delegate1;
-(void) loadDataWithFile:(int) index;
-(void) abortDownload;
@end

@interface NSObject (DataDropboxLoaderDelegate)
-(void) dataReady:(NSString*)fileName;
-(void) loadedMetadata:(NSArray*) metadata;
-(void) refreshLoadingView:(NSNumber*) concluded;


@end
