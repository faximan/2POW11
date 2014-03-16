//
//  POWTile.m
//  2POW11
//
//  Created by Alexander Faxå on 16/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import "POWTile.h"

#import "POWConstants.h"

@implementation POWTile

+ (POWTile *)zeroTile {
    POWTile *newTile = [[POWTile alloc] init];
    newTile.type = kPowTileTypeNone;
    return newTile;
}

+ (POWTile *)randomTile {
    POWTile *newTile = [[POWTile alloc] init];
    const float p = drand48();

    if (p < TILE_TYPE_REGULAR_PROB) {
        newTile.type = kPOWTileTypeRegular;

        // 50-50 between 1 and 2 as starting value
        newTile.value = (drand48() < 0.5) ? 1 : 2;
    } else  if (p < TILE_TYPE_REGULAR_PROB + TILE_TYPE_BLOCK_PROB) {
        newTile.type = kPowTileTypeBlock;
    } else {
        // Only kPowTileTypeBeam remains (p should be in the last TILE_TYPE_BEAM_PROB).
        newTile.type = kPowTileTypeBeam;
    }
    return newTile;
}

- (BOOL)canBeCollapsedWithTile:(POWTile *)tile {
    return (self.type == kPOWTileTypeRegular
            && tile.type == kPOWTileTypeRegular
            && self.value == tile.value);
}

@end
