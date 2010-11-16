//
//  LeavesViewController.h
//  Leaves
//
//  Created by Tom Brow on 4/18/10.
//  Copyright Tom Brow 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeavesView.h"

@interface LeavesViewController : UIViewController <LeavesViewDataSource, LeavesViewDelegate> {
	LeavesView *leavesView;
}
- (void) setCurrentPageIndex:(NSUInteger)aCurrentPageIndex;
-(void) setInteractionLocked;
@end

