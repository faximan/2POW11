//
//  POWViewController.m
//  2POW11
//
//  Created by Alexander Faxå on 11/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import "POWViewController.h"

#import "POWColorPicker.h"
#import "POWTileView.h"

#import <LARSAdController/LARSAdController.h>

@interface POWViewController() {
    // Tile matrix. (0,0) is lower left corner.
    unsigned int m_tiles[BOARD_HEIGHT+1][BOARD_WIDTH];  // +1 to accomodate for extra tile on top that can be collapsed downwards.
}
@property (nonatomic) unsigned int score;
@end

@implementation POWViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.bodyTileView.delegate = self;
    self.headTileView.delegate = self;
    [self newGame];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // Setup ad view controller.
    [[LARSAdController sharedManager] setPresentationType:LARSAdControllerPresentationTypeBottom];
    [[LARSAdController sharedManager] setPinningLocation:LARSAdControllerPinLocationBottom];
    [[LARSAdController sharedManager] addAdContainerToViewInViewController:self];
}

// Starts a new game
- (void)newGame {
    self.score = 0;

    // Reset tiles matrix.
    for (int r = 0; r < BOARD_HEIGHT+1; r++) {
        for (int c = 0; c < BOARD_WIDTH; c++) {
            m_tiles[r][c] = 0;
        }
    }
}

- (void)setScore:(unsigned int)score {
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"%u", self.score];
}

- (BOOL)canPlaceTileAtColumn:(unsigned int)column withValue:(int)value {
    NSAssert(column < BOARD_WIDTH, @"Illegal column");

    // A tile can be placed if the topmost slot is empty or if it has the same value
    // as the current tile (will collapse downwards).
    return (m_tiles[BOARD_HEIGHT-1][column] == 0 || m_tiles[BOARD_HEIGHT-1][column] == value);
}

// Returns true if there are available moves.
- (BOOL)hasAvailableMoves {
    for (int r = 0; r < BOARD_HEIGHT; r++) {
        for (int c = 0; c < BOARD_WIDTH; c++) {
            // If the board is not full then there are always moves.
            if (m_tiles[r][c] == 0) {
                return true;
            }

            // If two tiles next to each other are the same, you can do a swipe move.
            if (c != 0 && m_tiles[r][c-1] == m_tiles[r][c]) {
                return true;
            }
        }
    }
    return false;
}

- (void)insertTileWithValue:(unsigned int)value atColumn:(unsigned int)column {
    NSAssert([self canPlaceTileAtColumn:column withValue:value], @"Column is full");

    // Find first available index at the given column
    int height = 0;
    while (m_tiles[height][column] != 0) {
        height++;
    }
    m_tiles[height][column] = value;

    // Merge tiles downwards if we can.
    if (![self collapsedTilesDownwardsForColumn:column]) {

        // No tiles merged. Is this the end?
        if (![self hasAvailableMoves]) {
            [self newGame];
        }
    }
}

// -------- Move tiles around --------

// Moves all tiles in the given row as far to the left as possible. No merging of tiles.
// Returns true if at least one tile was moved or NO otherwise.
- (BOOL)moveAllTilesToTheLeftForRow:(unsigned int)r {
    BOOL movedTile = NO;
    for (int c = 0; c < BOARD_WIDTH; c++) {
        int current_pos = c;
        while (current_pos > 0) {
            if (m_tiles[r][current_pos] != 0 && m_tiles[r][current_pos-1] == 0) {
                m_tiles[r][current_pos-1] = m_tiles[r][current_pos];
                m_tiles[r][current_pos] = 0;
                movedTile = YES;
            }
            current_pos--;
        }
    }
    return movedTile;
}

// Returns true if at least two tiles were collapsed or NO otherwise.
- (BOOL)collapsedTilesDownwardsForColumn:(unsigned int)c {
    BOOL collapsedTiles = NO;

    do {
        unsigned int r = BOARD_HEIGHT;
        while (r > 0) {
            if (m_tiles[r][c] != 0 &&
                (m_tiles[r][c] == m_tiles[r - 1][c])) {
                self.score += m_tiles[r][c];
                m_tiles[r - 1][c] *= 2;
                m_tiles[r][c] = 0;
                collapsedTiles = YES;
            }
            r--;
        }

        // If tiles were moved downwards (holes created) then we
        // might need to repeat.
    } while([self moveAllTilesDownForColumn:c]);
    return collapsedTiles;
}

// Moves all tiles in the given column as far down as possible. No merging of tiles.
// Returns true if at least one tile was moved or NO otherwise.
- (BOOL)moveAllTilesDownForColumn:(unsigned int)c {
    BOOL movedTile = NO;
    for (int r = 0; r < BOARD_HEIGHT; r++) {
        int current_pos = r;
        while (current_pos > 0) {
            if (m_tiles[current_pos][c] != 0 && m_tiles[current_pos - 1][c] == 0) {
                m_tiles[current_pos - 1][c] = m_tiles[current_pos][c];
                m_tiles[current_pos][c] = 0;
                movedTile = YES;
            }
            current_pos--;
        }
    }
    return movedTile;
}

// Moves all tiles to the left, collapsing if two tiles with the same number get in
// touch with each other.
// Returns true if at least two tiles were collapsed or NO otherwise.
- (BOOL)collapsedTilesLeft {
    BOOL collapsedTiles = NO;
    for (int r = 0; r < BOARD_HEIGHT; r++) {
        [self moveAllTilesToTheLeftForRow:r];

        // Merge all tiles from the right that should merge.
        for (int c = BOARD_WIDTH - 1; c >= 1; c--) {
            if (m_tiles[r][c-1] == m_tiles[r][c]) {
                self.score += m_tiles[r][c];
                m_tiles[r][c-1] *= 2;
                m_tiles[r][c] = 0;
                collapsedTiles = YES;

                c--;  // Prevent "double merge".
            }
        }
        [self moveAllTilesToTheLeftForRow:r];
    }
    return collapsedTiles;
}

// Returns true if at least two tiles were collapsed or NO otherwise.
- (BOOL)collapsedTilesDownwards {
    BOOL collapsedTiles = NO;
    for (int c = 0; c < BOARD_WIDTH; c++) {
        collapsedTiles |= [self collapsedTilesDownwardsForColumn:c];
    }
    return collapsedTiles;
}

void swapTileValues(unsigned int* a, unsigned int* b) {
    unsigned int temp = *a;
    *a = *b;
    *b = temp;
}
- (void)rotateTileMatrix180Degrees {
    for (int r = 0; r < BOARD_HEIGHT / 2; r++) {
        for (int c = 0; c < BOARD_WIDTH; c++) {
            swapTileValues(&m_tiles[r][c], &m_tiles[BOARD_HEIGHT - 1 - r][BOARD_WIDTH - 1 - c]);
        }
    }
}

// ---------------------------------

// Updates the body view so that it matches the current tile matrix configuration.
- (void)syncBodyViewWithTileMatrix {
    [self.bodyTileView clearView];
    for (int c = 0; c < BOARD_WIDTH; c++) {
        for (int r = 0; r < BOARD_HEIGHT; r++) {
            if (m_tiles[r][c] != 0) {
                [self.bodyTileView addTileWithNumber:m_tiles[r][c] ToX:c y:r];
            }
        }
    }
}

#pragma mark POWTileHeadViewDelegate

- (NSArray *)illegalColumnsForValue:(unsigned int)value {
    NSMutableArray *illegalColumns = [[NSMutableArray alloc] init];
    for (int c = 0; c < BOARD_WIDTH; c++) {
        if (![self canPlaceTileAtColumn:c withValue:value]) {
            [illegalColumns addObject:[NSNumber numberWithInt:c]];
        }
    }
    return illegalColumns;
}


#pragma mark POWTileBodyViewDelegate

- (void)swipeLeftReceived {
    [self collapsedTilesLeft];
    [self collapsedTilesDownwards];

    [self.headTileView updateIllegalColumns];
    [self syncBodyViewWithTileMatrix];
}

- (void)swipeRightReceived {
    // Simulate moving right by flipping the matrix and then move left.
    [self rotateTileMatrix180Degrees];
    [self collapsedTilesLeft];
    [self rotateTileMatrix180Degrees];
    [self collapsedTilesDownwards];

    [self.headTileView updateIllegalColumns];
    [self syncBodyViewWithTileMatrix];
}

// Triggered when the user touches the view. Place the current tile where
// it is and create a new one.
- (void)tapReceived {
    int current_column = [self.headTileView currentColumn];
    // Make sure we really have a tile to drop.
    if (current_column < 0) {
        return;
    }

    [self insertTileWithValue:[self.headTileView currentValue] atColumn:current_column];
    [self.headTileView newTile];

    [self syncBodyViewWithTileMatrix];
}


@end
