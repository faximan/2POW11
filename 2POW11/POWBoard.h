//
//  POWBoard.h
//  2POW11
//
//  Created by Alexander Faxå on 16/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POWBoard : NSObject

- (void)resetBoard;

// Returns true if there are available moves.
- (BOOL)hasAvailableMoves;

// Returns YES if a tile with the given value can be placed in the given column
// or no otherwise. Consider calling this before -insertTileWithValue.
- (BOOL)canPlaceTileAtColumn:(unsigned int)c withValue:(int)value;

// Inserts a tile with the given value to the given column. Will crash if trying
// to insert a value to a column that is already full.
// Returns accumulated score.
- (unsigned int)insertTileWithValue:(unsigned int)value toColumn:(unsigned int)c;

// Moves all tiles to the left, collapsing if two tiles with the same number get in
// touch with each other.
// Returns accumulated score.
- (unsigned int)collapseTilesLeft;

// Moves all tiles to the right, collapsing if two tiles with the same number get in
// touch with each other.
// Returns accumulated score.
- (unsigned int)collapseTilesRight;

// Move all tiles downwards.
// Returns accumulated score.
- (unsigned int)collapseTilesDownwards;

// Returns the current value at the specified position.
// Returns 0 if there is no tile at the specified position.
- (unsigned int)valueForTileAtRow:(unsigned int)r column:(unsigned int)c;

@end
