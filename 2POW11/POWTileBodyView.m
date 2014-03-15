//
//  POWTileBodyView.m
//  2POW11
//
//  Created by Alexander Faxå on 15/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import "POWTileBodyView.h"
#import "POWTileView.h"

@implementation POWTileBodyView

- (void)clearView {
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
}

- (void)addTileWithNumber:(unsigned int)number ToX:(unsigned int)x y:(unsigned int)y {
    unsigned int tileX = x * TILE_SIZE;
    unsigned int tileY = (self.frame.size.height - TILE_SIZE) -  y * TILE_SIZE;
    NSAssert(tileX + TILE_SIZE <= self.frame.size.width, @"Illegal width");
    NSAssert(tileY + TILE_SIZE <= self.frame.size.height, @"Illegal height");

    POWTileView *newTile = [[POWTileView alloc]
                            initWithFrame:CGRectMake(tileX, tileY, TILE_SIZE, TILE_SIZE)];
    newTile.tileViewNumber = number;
    [self addSubview:newTile];
}


@end
