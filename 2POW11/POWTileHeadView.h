//
//  POWTileHeadView.h
//  2POW11
//
//  Created by Alexander Faxå on 15/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol POWTileHeadViewDelegate;

@interface POWTileHeadView : UIView

@property (nonatomic, weak) id<POWTileHeadViewDelegate> delegate;

// Adds a new tile to the head view (erases the current one if there is one).
- (void)newTile;

// Get the current column that the head tile is at or -1 if there is no tile in the head view.
- (int)currentColumn;

// Get the current value that the head tile has.
- (unsigned int)currentValue;

// Let the delegate update the illegal columns. newTile does this automatically.
- (void)updateIllegalColumns;

@end


@protocol POWTileHeadViewDelegate <NSObject>
@required
// Return a list of illegal columns
- (NSArray *)illegalColumnsForValue:(unsigned int)value;
@end
