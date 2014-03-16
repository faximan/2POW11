//
//  POWBoard.m
//  2POW11
//
//  Created by Alexander Faxå on 16/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import "POWBoard.h"

#import "POWConstants.h"
#import "POWTile.h"

@interface POWBoard() {
    // Tile matrix. (0,0) is lower left corner.
    POWTile *m_tiles[BOARD_HEIGHT + 1][BOARD_WIDTH];  // +1 to accomodate for extra tile on top that can be collapsed downwards.
}
@end

@implementation POWBoard

- (id)init {
    if (self = [super init]) {
        [self resetBoard];
    }
    return self;
}

- (void)resetBoard {
    for (int r = 0; r < BOARD_HEIGHT + 1; r++) {
        for (int c = 0; c < BOARD_WIDTH; c++) {
            m_tiles[r][c] = [POWTile zeroTile];
        }
    }
}

- (BOOL)canPlaceTile:(POWTile *)tile atColumn:(unsigned int)c {
    NSAssert(c < BOARD_WIDTH, @"Illegal column");

    // Beams will always go through.
    // If the column is not full, then it is ok.
    // If the column is full and the topmost tile is a number tile with the
    // same number as the given tile, then it is ok. Otherwise, NO.
    if (tile.type == kPowTileTypeBeam) {
        return YES;
    } else if (m_tiles[BOARD_HEIGHT-1][c].type == kPowTileTypeNone) {
        return YES;
    } else {
        return [m_tiles[BOARD_HEIGHT-1][c] canBeCollapsedWithTile:tile];
    }
}


// This one is a little tricky. There are a few cases where the user has available moves:
// 1. The topmost row is not filled.
// 2. The user can swipe left or right and collapse two or more tiles.
// 3. The user can swipe left or right causing some other tiles to fall down causing
//    1 or 2.
- (BOOL)hasAvailableMoves {
    if ([self hasAvailableMovesHelper]) {
        return true;
    }

    // Cache current board configuration in order to be able to do
    // "modifiable experiments" to m_tiles.
    POWTile *cache[BOARD_HEIGHT][BOARD_WIDTH];
    for (int r = 0; r < BOARD_HEIGHT; r++) {
        for (int c = 0; c < BOARD_WIDTH; c++) {
            cache[r][c] = m_tiles[r][c];
        }
    }
    BOOL hasMoves = NO;

    // Try swipe left.
    unsigned int wouldBePoints = [self collapseTilesLeft];
    wouldBePoints += [self collapseTilesDownwards];
    if (wouldBePoints > 0 || [self hasAvailableMovesHelper]) {
        hasMoves = YES;
    }
    // Reset.
    for (int r = 0; r < BOARD_HEIGHT; r++) {
        for (int c = 0; c < BOARD_WIDTH; c++) {
            m_tiles[r][c] = cache[r][c];
        }
    }

    // Repeat for right.
    wouldBePoints = [self collapseTilesRight];
    wouldBePoints += [self collapseTilesDownwards];
    if (wouldBePoints > 0 || [self hasAvailableMovesHelper]) {
        hasMoves = YES;
    }
    // Reset.
    for (int r = 0; r < BOARD_HEIGHT; r++) {
        for (int c = 0; c < BOARD_WIDTH; c++) {
            m_tiles[r][c] = cache[r][c];
        }
    }
    return hasMoves;
}

// Checks for 1 or 2 above.
-(BOOL)hasAvailableMovesHelper {
    for (int r = 0; r < BOARD_HEIGHT; r++) {
        for (int c = 0; c < BOARD_WIDTH; c++) {
            // 1.
            if ((r == BOARD_HEIGHT - 1) && (m_tiles[r][c].type == kPowTileTypeNone)) {
                return true;
            }

            // 2.
            int columnToLeft = c - 1;
            while (columnToLeft > 0) {
                if ([m_tiles[r][columnToLeft] canBeCollapsedWithTile:m_tiles[r][c]]) {
                    return true;
                } else if (m_tiles[r][columnToLeft].type == kPowTileTypeNone) {
                    columnToLeft--;
                } else {
                    break;  // Block tile or wrong number tile in between.
                }
            }
        }
    }
    return false;
}

- (unsigned int)insertTile:(POWTile *)tile toColumn:(unsigned int)c {
    NSAssert([self canPlaceTile:tile atColumn:c], @"Column is full");

    if (tile.type == kPowTileTypeBeam) {
        // Remove all blocks in this column.
        for (int r = 0; r < BOARD_HEIGHT; r++) {
            if (m_tiles[r][c].type == kPowTileTypeBlock) {
                m_tiles[r][c] = [POWTile zeroTile];
            }
        }
    } else {
        // Find first available index at the given column.
        int height = BOARD_HEIGHT;
        while (m_tiles[height-1][c].type == kPowTileTypeNone) {
            height--;
            if (height == 0) break;  // We must be able to put it last.
        }
        m_tiles[height][c] = tile;
    }

    // Merge tiles downwards if we can.
    return [self collapseTilesDownwardsForColumn:c];
}

- (POWTile *)tileAtRow:(unsigned int)r column:(unsigned int)c {
    NSAssert(r < BOARD_HEIGHT, @"Illegal row");
    NSAssert(c < BOARD_WIDTH, @"Illegal column");
    return (m_tiles[r][c].type == kPowTileTypeNone) ? nil : m_tiles[r][c];
}

// -------- Move tiles around --------
// Most functions returns the number of points awarded for doing this move.

// Moves all tiles in the given row as far to the left as possible. No merging of tiles.
- (void)moveAllTilesToTheLeftForRow:(unsigned int)r {
    for (int c = 0; c < BOARD_WIDTH; c++) {
        int current_pos = c;
        while (current_pos > 0) {
            if (m_tiles[r][current_pos].type == kPOWTileTypeRegular
                && m_tiles[r][current_pos-1].type == kPowTileTypeNone) {
                m_tiles[r][current_pos-1] = m_tiles[r][current_pos];
                m_tiles[r][current_pos] = [POWTile zeroTile];
            }
            current_pos--;
        }
    }
}

- (unsigned int)collapseTilesDownwardsForColumn:(unsigned int)c {
    unsigned int points = 0;

    do {
        unsigned int r = BOARD_HEIGHT;
        while (r > 0) {
            if ([m_tiles[r][c] canBeCollapsedWithTile:m_tiles[r - 1][c]]) {
                points += m_tiles[r][c].value;
                m_tiles[r - 1][c].value *= 2;
                m_tiles[r][c] = [POWTile zeroTile];
            }
            r--;
        }

        // If tiles were moved downwards (holes created) then we
        // might need to repeat.
    } while([self moveAllTilesDownwardsForColumn:c]);
    return points;
}

// Moves all tiles in the given column as far down as possible. No merging of tiles.
// Returns YES if at least one tile was moved.
- (BOOL)moveAllTilesDownwardsForColumn:(unsigned int)c {
    BOOL movedTile = NO;
    for (int r = 0; r < BOARD_HEIGHT; r++) {
        int current_pos = r;
        while (current_pos > 0) {
            if (m_tiles[current_pos][c].type == kPOWTileTypeRegular
                && m_tiles[current_pos - 1][c].type == kPowTileTypeNone) {
                m_tiles[current_pos - 1][c] = m_tiles[current_pos][c];
                m_tiles[current_pos][c] = [POWTile zeroTile];
                movedTile = YES;
            }
            current_pos--;
        }
    }
    return movedTile;
}

- (unsigned int)collapseTilesDownwards {
    unsigned int points = 0;
    for (int c = 0; c < BOARD_WIDTH; c++) {
        points += [self collapseTilesDownwardsForColumn:c];
    }
    return points;
}

- (unsigned int)collapseTilesLeft {
    unsigned int points = 0;
    for (int r = 0; r < BOARD_HEIGHT; r++) {
        [self moveAllTilesToTheLeftForRow:r];

        // Merge all tiles from the right that should merge.
        for (int c = BOARD_WIDTH - 1; c >= 1; c--) {
            if ([m_tiles[r][c-1] canBeCollapsedWithTile:m_tiles[r][c]]) {
                points += m_tiles[r][c].value;
                m_tiles[r][c-1].value *= 2;
                m_tiles[r][c] = [POWTile zeroTile];

                c--;  // Prevent "double merge".
            }
        }
        [self moveAllTilesToTheLeftForRow:r];
    }
    return points;
}

// Simulate moving right by flipping the matrix and then move left.
- (unsigned int)collapseTilesRight {
    [self rotateTileMatrix180Degrees];
    unsigned int points = [self collapseTilesLeft];
    [self rotateTileMatrix180Degrees];
    return points;
}

- (void)rotateTileMatrix180Degrees {
    for (int r = 0; r < BOARD_HEIGHT / 2; r++) {
        for (int c = 0; c < BOARD_WIDTH; c++) {
            // Swap (r,c) with (height-1-r,width-1-c).
            POWTile *temp = m_tiles[r][c];
            m_tiles[r][c] = m_tiles[BOARD_HEIGHT - 1 - r][BOARD_WIDTH - 1 - c];
            m_tiles[BOARD_HEIGHT - 1 - r][BOARD_WIDTH - 1 - c]= temp;
        }
    }
}

// ---------------------------------

@end
