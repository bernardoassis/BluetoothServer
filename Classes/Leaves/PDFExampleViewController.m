    //
//  PDFExampleViewController.m
//  Leaves
//
//  Created by Tom Brow on 4/19/10.
//  Copyright 2010 Tom Brow. All rights reserved.
//

#import "PDFExampleViewController.h"
#import "Utilities.h"

@implementation PDFExampleViewController

- (id)initWithFilePath:(NSString*) filePath {
    if (self = [super init]) {
		NSURL *pdfURL = [NSURL fileURLWithPath:filePath];
		pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
		self->_page = 1;
    }
    return self;
}

- (id)initWithPDFFile:(CGPDFDocumentRef) pdfFile andPage:(int) page {
    if (self = [super init]) {
		[super setInteractionLocked];
		pdf = pdfFile;
		self->_page = page;
    }
    return self;
}

- (void)dealloc {
	CGPDFDocumentRelease(pdf);
    [super dealloc];
}

- (void) viewWillAppear:(BOOL)animated 
{
	[self.navigationController setNavigationBarHidden:YES];
}

- (void) displayPageNumber:(NSUInteger)pageNumber {
	self.navigationItem.title = [NSString stringWithFormat:
								 @"Page %u of %u", 
								 pageNumber, 
								 CGPDFDocumentGetNumberOfPages(pdf)];
}

#pragma mark  LeavesViewDelegate methods

- (void) leavesView:(LeavesView *)leavesView willTurnToPageAtIndex:(NSUInteger)pageIndex {
	[self displayPageNumber:pageIndex + 1];
}

#pragma mark LeavesViewDataSource methods

- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)leavesView {
	return CGPDFDocumentGetNumberOfPages(pdf);
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
	CGPDFPageRef page = CGPDFDocumentGetPage(pdf, index + 1);
	CGAffineTransform transform = aspectFit(CGPDFPageGetBoxRect(page, kCGPDFMediaBox), CGContextGetClipBoundingBox(ctx));
	CGContextConcatCTM(ctx, transform);
	CGContextDrawPDFPage(ctx, page);
}

#pragma mark UIViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	leavesView.backgroundRendering = YES;
	[super setCurrentPageIndex:(self->_page)];
	[self displayPageNumber:(self->_page)];
}

@end
