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

@interface POWViewController() {
    // Tile matrix. (0,0) is lower left corner.
    unsigned int m_tiles[BOARD_HEIGHT][BOARD_WIDTH];
}
@property (nonatomic) unsigned int score;
@end

@implementation POWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self newGame];
}

// Starts a new game
- (void)newGame {
    self.score = 0;

    // Reset tiles matrix.
    for (int i = 0; i < BOARD_HEIGHT; i++) {
        for (int j = 0;j < BOARD_WIDTH; j++) {
            m_tiles[i][j] = 0;
        }
    }

    [self.headTileView resetSkippedColumns];
}

- (void)setScore:(unsigned int)score {
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"%u", _score];
}

- (BOOL)canPlaceTileAtColumn:(unsigned int)column {
    NSAssert(column < BOARD_WIDTH, @"Illegal column");
    return (m_tiles[BOARD_HEIGHT-1][column] == 0);
}

// TODO: Implement these
- (void)tiltLeft {}
- (void)tiltRight {}

- (void)insertTileWithNumber:(unsigned int)number atColumn:(unsigned int)column {
    NSAssert([self canPlaceTileAtColumn:column], @"Column is full");

    // Find first available index at the given column
    int height = 0;
    while (m_tiles[height][column] != 0) {
        height++;
    }
    m_tiles[height][column] = number;

    // Merge tiles downwards if we can.
    if (![self collapsedTilesForColumn:column]) {
        // If this was the last tile on this column, make sure we can't add any more tiles to it.
        if (height == BOARD_HEIGHT - 1) {
            [self columnIsFull:(unsigned int)column];
        }
    }

    // Update body view.
    [self syncBodyViewWithTileMatrix];
}

// Returns true if at least two tiles were collapsed or NO otherwise.
- (BOOL)collapsedTilesForColumn:(unsigned int)column {
    BOOL collapsedTiles = NO;

    unsigned int currentRow = BOARD_HEIGHT - 1;
    while (currentRow > 0) {
        if (m_tiles[currentRow][column] == 0) {
            currentRow--;
        } else if (m_tiles[currentRow][column] == m_tiles[currentRow - 1][column]) {
            self.score += m_tiles[currentRow][column];
            m_tiles[currentRow - 1][column] *= 2;
            m_tiles[currentRow][column] = 0;
            currentRow--;
            collapsedTiles = YES;
        } else {
            break;
        }
    }
    return collapsedTiles;
}

- (void)columnIsFull:(unsigned int)column {
    // Have we lost?
    if ([self isBoardFull]) {
        [self newGame];
    } else {
        [self.headTileView skipColumn:column];
    }
}

// Returns YES if all tiles on the board are occupied.
- (BOOL)isBoardFull {
    for (int i = 0; i < BOARD_HEIGHT; i++) {
        for (int j = 0; j < BOARD_WIDTH; j++) {
            if (m_tiles[i][j] == 0) {
                return false;
            }
        }
    }
    return true;
}

// Updates the body view so that it matches the current tile matrix configuration.
- (void)syncBodyViewWithTileMatrix {
    [self.bodyTileView clearView];
    for (int i = 0; i < BOARD_HEIGHT; i++) {
        for (int j = 0;j < BOARD_WIDTH; j++) {
            if (m_tiles[i][j] != 0) {
                [self.bodyTileView addTileWithNumber:m_tiles[i][j] ToX:j y:i];
            }
        }
    }
}

// Triggered when the user touches the view. Place the current tile where
// it is and create a new one.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    unsigned int current_column = [self.headTileView currentColumn];
    unsigned int current_value = [self.headTileView currentValue];
    [self insertTileWithNumber:current_value atColumn:current_column];
    [self.headTileView newTile];
}



@end
