//
//  PDFExampleViewController.h
//  Leaves
//
//  Created by Tom Brow on 4/19/10.
//  Copyright 2010 Tom Brow. All rights reserved.
//

#import "LeavesViewController.h"

@interface PDFExampleViewController : LeavesViewController {
	CGPDFDocumentRef pdf;
	int _page;
}
- (id)initWithFilePath:(NSString*) filePath;
- (id)initWithPDFFile:(CGPDFDocumentRef) pdfFile andPage:(int) page;
@end
