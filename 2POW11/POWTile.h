//
//  POWTile.h
//  2POW11
//
//  Created by Alexander Faxå on 16/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kPowTileTypeNone,
    kPOWTileTypeRegular,
    kPowTileTypeBlock,
    kPowTileTypeBeam
} POWTileType;

@interface POWTile : NSObject

@property (nonatomic) POWTileType type;

// Only valid if type == kPOWTileTypeRegular
@property (nonatomic) unsigned int value;

// Returns an empty tile.
+ (POWTile *)zeroTile;
+ (POWTile *)randomTile;

// Returns true if this tile can be collapsed with the passed tile if opportunity is given.
- (BOOL)canBeCollapsedWithTile:(POWTile *)tile;

@end
