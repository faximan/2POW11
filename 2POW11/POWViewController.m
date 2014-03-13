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
        // Add a number to a random free tile.
        const unsigned int randTileIndex = arc4random() % emptySquares.count;
        const unsigned int index = [(NSNumber *)[emptySquares objectAtIndex:randTileIndex] intValue];
        POWTile *randTile = self.tiles[index];

        // Assign 1 or 2 to the new tile with 50-50 probability.
        randTile.number = (drand48() < 0.5) ? 1 : 2;
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


- (void)moveTileAsFarAsPossibleToTheLeftWithIndex:(unsigned int)index {
    while (1) {
        int nextIdx = [self indexOfTileNextTo:index dx:-1 dy:0];
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

// Moves all tiles to the left, merging the tiles that fit together.
- (void)moveLeft {
    // Moves all tiles as far to the left as possible.
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            [self moveTileAsFarAsPossibleToTheLeftWithIndex:j*4+i];
        }
    }

    // Merge the tiles that have the same number and now touches each other.
    int moved[16];
    memset(moved, 0, sizeof(moved));
    for (int i = 3; i > 0; i--) {
        for (int j = 0; j < 4; j++) {
            const unsigned int curIdx = j * 4 + i;
            // Do not move the same tile twice.
            if (moved[curIdx])
                continue;
            int nextIdx = [self indexOfTileNextTo:curIdx dx:-1 dy:0];
            POWTile *curTile = self.tiles[curIdx];
            POWTile *nextTile = self.tiles[nextIdx];

            // Is curTile mergeable with nextTile?
            if (nextTile.number == curTile.number) {
                nextTile.number *= 2;
                curTile.number = 0;
                 moved[nextIdx] = 1;
            }
        }
    }

    // Fill holes that might have been created.
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            const unsigned int curIdx = j*4+i;
            if (moved[curIdx])
                continue;
            [self moveTileAsFarAsPossibleToTheLeftWithIndex:curIdx];
        }
    }
}

- (void)rotateTileMatrix90Degrees {
    for (int x = 0; x < 2; x++) {
        for (int y = 0; y < 2; y++) {
            unsigned int temp = ((POWTile *)self.tiles[x + y*4]).number;
            ((POWTile *)self.tiles[x + 4*y]).number = ((POWTile *)self.tiles[y + 4*(3-x)]).number;
            ((POWTile *)self.tiles[y + 4*(3-x)]).number =  ((POWTile *)self.tiles[3-x + 4*(3-y)]).number;
            ((POWTile *)self.tiles[3-x + 4*(3-y)]).number =  ((POWTile *)self.tiles[3-y + 4*x]).number;
            ((POWTile *)self.tiles[3-y + 4*x]).number = temp;
        }
    }
}

- (IBAction)left {
    [self moveLeft];
    [self nextState];
}

- (IBAction)right {
    [self rotateTileMatrix90Degrees];
    [self rotateTileMatrix90Degrees];
    [self moveLeft];
    [self rotateTileMatrix90Degrees];
    [self rotateTileMatrix90Degrees];
    [self nextState];
}

- (IBAction)down {
    [self rotateTileMatrix90Degrees];
    [self moveLeft];
    [self rotateTileMatrix90Degrees];
    [self rotateTileMatrix90Degrees];
    [self rotateTileMatrix90Degrees];
    [self nextState];
}

- (IBAction)up {
    [self rotateTileMatrix90Degrees];
    [self rotateTileMatrix90Degrees];
    [self rotateTileMatrix90Degrees];
    [self moveLeft];
    [self rotateTileMatrix90Degrees];
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
