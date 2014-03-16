//
//  POWTile.m
//  2POW11
//
//  Created by Alexander Faxå on 16/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import "POWTile.h"

@implementation POWTile

+ (POWTile *)zeroTile {
    POWTile *newTile = [[POWTile alloc] init];
    newTile.value = 0;
    return newTile;
}

+ (unsigned int)getRandomNewTileNumber {
    if (drand48() < 0.25) {
        return 4;
    } else if (drand48() < 0.5) {
        return 2;
    } else {
        return 1;
    }
}

@end
