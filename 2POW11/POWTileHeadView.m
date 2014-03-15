//
//  POWTileHeadView.m
//  2POW11
//
//  Created by Alexander Faxå on 15/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import "POWTileHeadView.h"

#import "POWTileView.h"

#define MOVE_SPEED 0.5 // Time in seconds for the head tile to move to the next position.

@interface POWTileHeadView() {
    int m_columns_to_skip[BOARD_WIDTH];
}

@property (nonatomic) unsigned int tilePosition;  // Current x position for head tile.
@property (nonatomic, strong) POWTileView *headTile;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation POWTileHeadView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.headTile = [[POWTileView alloc] initWithFrame:CGRectMake(0, 0, TILE_SIZE, TILE_SIZE)];
        [self addSubview:self.headTile];
        [self resetSkippedColumns];
        [self newTile];
    }
    return self;
}


// Sets the position for the head tile based on the current tilePosition.
- (void)setPositionForHeadTile {
    self.headTile.frame = CGRectMake(self.tilePosition * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE);
}

- (void)setTilePosition:(unsigned int)tilePosition {
    _tilePosition = tilePosition;
    [self setPositionForHeadTile];
}

// Moves the tile one step to the right (wrapping around if necessary).
- (void)nextTilePosition {
    do {
        self.tilePosition = (self.tilePosition + 1) % BOARD_WIDTH;
    } while (m_columns_to_skip[self.tilePosition] != 0);
}

// Randomizes a number as the starting number for this tile.
- (unsigned int)randomizeHeadTileNumber {
    return (drand48() < 0.5) ? 1 : 2;
}

- (void)resetTimer {
    // Stop the current timer if there is one.
    if (self.timer.isValid) {
        [self.timer invalidate];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:MOVE_SPEED
                                                  target:self
                                                selector:@selector(nextTilePosition)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)newTile {
    self.headTile.tileViewNumber = [self randomizeHeadTileNumber];
    self.tilePosition = [self firstAvailableColumn];

    // Update position every MOVE_SPEED
    [self resetTimer];
    
}

- (unsigned int)currentColumn {
    return self.tilePosition;
}

- (unsigned int)currentValue {
    return self.headTile.tileViewNumber;
}

- (void)resetSkippedColumns {
    for (int i = 0; i < BOARD_WIDTH; i++) {
        m_columns_to_skip[i] = 0;
    }
}

- (void)skipColumn:(unsigned int)column {
    NSAssert(column < BOARD_WIDTH, @"Illegal column");
    m_columns_to_skip[column] = 1;
}

- (void)unSkipColumn:(unsigned int)column {
    NSAssert(column < BOARD_WIDTH, @"Illegal column");
    m_columns_to_skip[column] = 0;
}

- (unsigned int)firstAvailableColumn {
    for (int i = 0; i < BOARD_WIDTH; i++) {
        if (m_columns_to_skip[i] == 0) {
            return i;
        }
    }
    NSAssert(0, @"No availble columns");
    return 0;  // Error.
}


@end
