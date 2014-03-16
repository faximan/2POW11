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
    BOOL m_columns_to_skip[BOARD_WIDTH];
}

@property (nonatomic) int tilePosition;  // Current x position for head tile.
@property (nonatomic, strong) POWTileView *headTile;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation POWTileHeadView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.headTile = [[POWTileView alloc] initWithFrame:CGRectMake(0, 0, TILE_SIZE, TILE_SIZE)];
        [self newTile];
    }
    return self;
}


// Sets the position for the head tile based on the current tilePosition.
- (void)setPositionForHeadTile {
    [self.headTile removeFromSuperview];
    if (self.tilePosition >= 0) {
        self.headTile.frame = CGRectMake(self.tilePosition * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE);
        [self addSubview:self.headTile];
    }
}

- (void)setTilePosition:(int)tilePosition {
    _tilePosition = tilePosition;
    [self setPositionForHeadTile];
}

// Moves the tile one step to the right (wrapping around if necessary).
- (void)nextTilePosition {
    if (![self hasAvailableColumns]) {
        return;
    }

    do{
        self.tilePosition = (self.tilePosition + 1) % BOARD_WIDTH;
    } while (m_columns_to_skip[self.tilePosition]);
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
    [self.headTile removeFromSuperview];
    [self.headTile setRandomNumber];

    [self updateIllegalColumns];
    self.tilePosition = [self firstAvailableColumn];
    // Update position every MOVE_SPEED
    [self resetTimer];
}

- (int)currentColumn {
    return self.tilePosition;
}

- (unsigned int)currentValue {
    return self.headTile.tileViewNumber;
}

- (void)updateIllegalColumns {
    NSArray *illegalColumns = [self.delegate illegalColumnsForValue:[self currentValue]];

    // Reset columns
    for (int i = 0; i < BOARD_WIDTH; i++) {
        m_columns_to_skip[i] = NO;
    }

    for (NSNumber *illegalColumn in illegalColumns) {
        m_columns_to_skip[[illegalColumn intValue]] = YES;
    }

    // Move tile if this column is not legal.
    if (m_columns_to_skip[[self currentColumn]]) {
        [self nextTilePosition];
    }
}

- (BOOL)hasAvailableColumns {
    return ([self firstAvailableColumn] != -1);
}

- (int)firstAvailableColumn {
    for (int c = 0; c < BOARD_WIDTH; c++) {
        if (!m_columns_to_skip[c]) {
            return c;
        }
    }
    return -1;  // No available columns.
}


@end
