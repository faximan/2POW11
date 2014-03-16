//
//  POWBoard.h
//  2POW11
//
//  Created by Alexander Faxå on 16/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "POWTile.h"

@interface POWBoard : NSObject

- (void)resetBoard;

// Returns true if there are available moves.
- (BOOL)hasAvailableMoves;

// Returns YES if a tile with the given tile can be placed in the given column
// or no otherwise. Consider calling this before -insertTile.
- (BOOL)canPlaceTile:(POWTile *)tile atColumn:(unsigned int)c;

// Inserts a tile to the given column. Will crash if trying
// to insert a tile to a column that is already full.
// Returns accumulated score.
- (unsigned int)insertTile:(POWTile *)tile toColumn:(unsigned int)c;

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

// Returns the current tile at the specified position.
// Returns nil if there is no tile at the specified position.
- (POWTile *)tileAtRow:(unsigned int)r column:(unsigned int)c;

@end
