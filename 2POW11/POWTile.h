//
//  POWTile.h
//  2POW11
//
//  Created by Alexander Faxå on 16/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POWTile : NSObject

@property (nonatomic) unsigned int value;

// Returns an empty tile.
+ (POWTile *)zeroTile;

// Returns a random new tile number.
+ (unsigned int)getRandomNewTileNumber;

@end
