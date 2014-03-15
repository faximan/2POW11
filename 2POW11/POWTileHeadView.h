//
//  POWTileHeadView.h
//  2POW11
//
//  Created by Alexander Faxå on 15/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POWTileHeadView : UIView

// Adds a new tile to the head view (erases the current one if there is one).
- (void)newTile;

// Get the current column that the head tile is at or -1 if there is no tile in the head view.
- (int)currentColumn;

// Get the current value that the head tile has.
- (unsigned int)currentValue;

// Skip the passed in column when looping through available columns.
- (void)skipColumn:(unsigned int)column;

// Unskip the passed in column when looping through available columns.
- (void)unSkipColumn:(unsigned int)column;

// Resets all columns to be loopable
- (void)resetSkippedColumns;

@end
