//
//  POWViewController.m
//  2POW11
//
//  Created by Alexander Faxå on 11/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import "POWViewController.h"

#import "POWColorPicker.h"
#import "POWTile.h"

#define WINNING_NUMBER 32

@interface POWViewController() <POWTileDelegate>
@property (nonatomic, strong) NSMutableArray *tiles;
@end

@implementation POWViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // The order of an IBOutletCollection is not known. Sort by tag propery.
    [self.tilesViews sortedArrayUsingComparator:^NSComparisonResult
     (id objA, id objB){
        return(([objA tag] < [objB tag]) ? NSOrderedAscending  :
               ([objA tag] > [objB tag]) ? NSOrderedDescending :
               NSOrderedSame);
     }];

    self.tiles = [[NSMutableArray alloc] init];
    for (unsigned int i = 0; i < 16; i++) {
        POWTile *tile = [[POWTile alloc] initWithIndex:i];
        tile.delegate = self;
        [self.tiles addObject:tile];
    }

    unsigned int startTileIndex = arc4random() % 16;
    POWTile *startTile = self.tiles[startTileIndex];
    startTile.number = 1;
}

- (void)nextState {
    // Check for winning and loosing.
    NSMutableArray *emptySquares = [[NSMutableArray alloc] init];
    for (int i = 0; i < 16; i++) {
        POWTile *curTile = self.tiles[i];
        const unsigned int curNbr = curTile.number;
        if (curNbr == 0) {
            [emptySquares addObject:[NSNumber numberWithInt:i]];
        }
        if (curNbr == WINNING_NUMBER) {
            NSLog(@"WIN!");
        }
    }

    if (emptySquares.count == 0) {
        NSLog(@"LOSE!");
    } else {
        const unsigned int randTileIndex = arc4random() % emptySquares.count;
        const unsigned int index = [(NSNumber *)[emptySquares objectAtIndex:randTileIndex] intValue];
        POWTile *randTile = self.tiles[index];
        NSAssert(randTile.number == 0, @"Tried to update a non-empty tile");

        // Assign 1 to the new tile.
        randTile.number = 1;
    }
}


- (int)indexOfTileNextTo:(unsigned int)tile dx:(int)dx dy:(int)dy {
    int x = tile % 4;
    int y = tile / 4;
    x += dx;
    y += dy;
    if (x < 0 || y < 0 || x > 3 || y > 3) return -1;  // Tile outside of game.
    return y * 4 + x;
}


// Returns the index of the tile we moved to or -1 otherwise.
- (int)tryMergeTileWithIndex:(unsigned int)index dx:(int)dx dy:(int)dy {
    int nextIdx = [self indexOfTileNextTo:index dx:dx dy:dy];
    NSAssert(nextIdx >= 0, @"Tried to move outside of board");

    POWTile *curTile = self.tiles[index];
    POWTile *nextTile = self.tiles[nextIdx];
    if (nextTile.number == curTile.number) {
        nextTile.number *= 2;
        curTile.number = 0;
        return nextIdx;
    }
    return -1;
}

- (void)moveTileWithIndex:(unsigned int)index asFarAsPossibleDx:(int)dx dy:(int)dy {
    while (1) {
        int nextIdx = [self indexOfTileNextTo:index dx:dx dy:dy];
        if (nextIdx < 0) return;  // Reached border.
        POWTile *curTile = self.tiles[index];
        POWTile *nextTile = self.tiles[nextIdx];

        // Make sure we don't overwrite an existing tile.
        if (nextTile.number != 0) {
            return;
        }
        nextTile.number = curTile.number;
        curTile.number = 0;
        index = nextIdx;
    }
}

- (IBAction)left {
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            [self moveTileWithIndex:j*4+i asFarAsPossibleDx:-1 dy:0];
        }
    }


    int moved[16];
    memset(moved, 0, sizeof(moved));
    for (int i = 3; i > 0; i--) {
        for (int j = 0; j < 4; j++) {
            const unsigned int curIdx = j * 4 + i;
            // Do not move the same tile twice.
            if (moved[curIdx])
                continue;
            int movedToIdx = [self tryMergeTileWithIndex:curIdx dx:-1 dy:0];
            if (movedToIdx >= 0) {
                moved[movedToIdx] = 1;
            }
        }
    }

    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            const unsigned int curIdx = j*4+i;
            if (moved[curIdx])
                continue;
            [self moveTileWithIndex:curIdx asFarAsPossibleDx:-1 dy:0];
        }
    }
    [self nextState];
}

- (IBAction)right {
    for (int i = 3; i >= 0; i--) {
        for (int j = 0; j < 4; j++) {
            [self moveTileWithIndex:j*4+i asFarAsPossibleDx:1 dy:0];
        }
    }

    int moved[16];
    memset(moved, 0, sizeof(moved));
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 4; j++) {
            const unsigned int curIdx = j * 4 + i;
            // Do not move the same tile twice.
            if (moved[curIdx])
                continue;
            int movedToIdx = [self tryMergeTileWithIndex:curIdx dx:1 dy:0];
            if (movedToIdx >= 0) {
                moved[movedToIdx] = 1;
            }
        }
    }
    for (int i = 3; i >= 0; i--) {
        for (int j = 0; j < 4; j++) {
            const unsigned int curIdx = j*4+i;
            if (moved[curIdx])
                continue;
            [self moveTileWithIndex:curIdx asFarAsPossibleDx:1 dy:0];
        }
    }
    [self nextState];
}

- (IBAction)up {
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            [self moveTileWithIndex:j*4+i asFarAsPossibleDx:0 dy:-1];
        }
    }

    int moved[16];
    memset(moved, 0, sizeof(moved));
    for (int i = 3; i > 0; i--) {
        for (int j = 0; j < 4; j++) {
            const unsigned int curIdx = i * 4 + j;
            // Do not move the same tile twice.
            if (moved[curIdx])
                continue;
            int movedToIdx = [self tryMergeTileWithIndex:curIdx dx:0 dy:-1];
            if (movedToIdx >= 0) {
                moved[movedToIdx] = 1;
            }
        }
    }
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            const unsigned int curIdx = j*4+i;
            if (moved[curIdx])
                continue;
            [self moveTileWithIndex:curIdx asFarAsPossibleDx:0 dy:-1];
        }
    }
    [self nextState];
}

- (IBAction)down {
    for (int i = 0; i < 4; i++) {
        for (int j = 3; j >= 0; j--) {
            [self moveTileWithIndex:j*4+i asFarAsPossibleDx:0 dy:1];
        }
    }

    int moved[16];
    memset(moved, 0, sizeof(moved));
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 4; j++) {
            const unsigned int curIdx = i * 4 + j;
            // Do not move the same tile twice.
            if (moved[curIdx])
                continue;
            int movedToIdx = [self tryMergeTileWithIndex:curIdx dx:0 dy:1];
            if (movedToIdx >= 0) {
                moved[movedToIdx] = 1;
            }
        }
    }
    for (int i = 0; i < 4; i++) {
        for (int j = 3; j >= 0; j--) {
            const unsigned int curIdx = j*4+i;
            if (moved[curIdx])
                continue;
            [self moveTileWithIndex:curIdx asFarAsPossibleDx:0 dy:1];
        }
    }
    [self nextState];
}


#pragma mark POWTileDelegate

- (void)powTileDelegate:(POWTile *)sender
  didUpdateTileToNumber:(unsigned int)number {
    // Assume that the sender index is between 0 and 15 inclusive.
    POWTileView *tileView = self.tilesViews[[sender getIndex]];

    if (sender.number != 0)
        tileView.label.text = [NSString stringWithFormat:@"%d", sender.number];
    else
        tileView.label.text = @"";
    tileView.backgroundColor = [POWColorPicker colorForNumber:sender.number];
}

@end
