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

- (BOOL)canPlaceTileAtColumn:(unsigned int)c withValue:(int)value {
    NSAssert(c < BOARD_WIDTH, @"Illegal column");

    // A tile can be placed if the topmost slot is empty or if it has the same value
    // as the current tile (will collapse downwards).
    return (m_tiles[BOARD_HEIGHT-1][c].value == 0 ||
            m_tiles[BOARD_HEIGHT-1][c].value == value);
}

// Returns true if there are available moves.
- (BOOL)hasAvailableMoves {
    for (int r = 0; r < BOARD_HEIGHT; r++) {
        for (int c = 0; c < BOARD_WIDTH; c++) {
            // If the board is not full then there are always moves.
            if (m_tiles[r][c].value == 0) {
                return true;
            }

            // If two tiles next to each other are the same, you can do a swipe move.
            if (c != 0 && m_tiles[r][c-1].value == m_tiles[r][c].value) {
                return true;
            }
        }
    }
    return false;
}

- (unsigned int)insertTileWithValue:(unsigned int)value toColumn:(unsigned int)c {
    NSAssert([self canPlaceTileAtColumn:c withValue:value], @"Column is full");

    // Find first available index at the given column
    int height = 0;
    while (m_tiles[height][c].value != 0) {
        height++;
    }
    m_tiles[height][c].value = value;

    // Merge tiles downwards if we can.
    return [self collapseTilesDownwardsForColumn:c];
}

- (unsigned int)valueForTileAtRow:(unsigned int)r column:(unsigned int)c {
    NSAssert(r < BOARD_HEIGHT, @"Illegal row");
    NSAssert(c < BOARD_WIDTH, @"Illegal column");
    return m_tiles[r][c].value;
}

// -------- Move tiles around --------
// Most functions returns the number of points awarded for doing this move.

// Moves all tiles in the given row as far to the left as possible. No merging of tiles.
- (void)moveAllTilesToTheLeftForRow:(unsigned int)r {
    for (int c = 0; c < BOARD_WIDTH; c++) {
        int current_pos = c;
        while (current_pos > 0) {
            if (m_tiles[r][current_pos].value != 0 && m_tiles[r][current_pos-1].value == 0) {
                m_tiles[r][current_pos-1].value = m_tiles[r][current_pos].value;
                m_tiles[r][current_pos].value = 0;
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
            if (m_tiles[r][c].value != 0 &&
                (m_tiles[r][c].value == m_tiles[r - 1][c].value)) {
                points += m_tiles[r][c].value;
                m_tiles[r - 1][c].value *= 2;
                m_tiles[r][c].value = 0;
            }
            r--;
        }

        // If tiles were moved downwards (holes created) then we
        // might need to repeat.
    } while([self moveAllTilesDownForColumn:c]);
    return points;
}

// Moves all tiles in the given column as far down as possible. No merging of tiles.
// Returns YES if at least one tile was moved.
- (BOOL)moveAllTilesDownForColumn:(unsigned int)c {
    BOOL movedTile = NO;
    for (int r = 0; r < BOARD_HEIGHT; r++) {
        int current_pos = r;
        while (current_pos > 0) {
            if (m_tiles[current_pos][c].value != 0 && m_tiles[current_pos - 1][c].value == 0) {
                m_tiles[current_pos - 1][c].value = m_tiles[current_pos][c].value;
                m_tiles[current_pos][c].value = 0;
                movedTile = YES;
            }
            current_pos--;
        }
    }
    return movedTile;
}

- (unsigned int)collapseTilesLeft {
    unsigned int points = 0;
    for (int r = 0; r < BOARD_HEIGHT; r++) {
        [self moveAllTilesToTheLeftForRow:r];

        // Merge all tiles from the right that should merge.
        for (int c = BOARD_WIDTH - 1; c >= 1; c--) {
            if (m_tiles[r][c-1].value == m_tiles[r][c].value) {
                points += m_tiles[r][c].value;
                m_tiles[r][c-1].value *= 2;
                m_tiles[r][c].value = 0;

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

- (unsigned int)collapseTilesDownwards {
    unsigned int points = 0;
    for (int c = 0; c < BOARD_WIDTH; c++) {
        points += [self collapseTilesDownwardsForColumn:c];
    }
    return points;
}

- (void)rotateTileMatrix180Degrees {
    for (int r = 0; r < BOARD_HEIGHT / 2; r++) {
        for (int c = 0; c < BOARD_WIDTH; c++) {

            // Swap (r,c) with (height-1-r,width-1-c).
            unsigned int temp = m_tiles[r][c].value;
            m_tiles[r][c].value = m_tiles[BOARD_HEIGHT - 1 - r][BOARD_WIDTH - 1 - c].value;
            m_tiles[BOARD_HEIGHT - 1 - r][BOARD_WIDTH - 1 - c].value = temp;
        }
    }
}

// ---------------------------------

@end
