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

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        // Add swipe recognizers
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(swipeLeftReceived)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeLeft];

        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(swipeRightReceived)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeRight];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(tapReceived)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

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


- (void)tapReceived {
    [self.delegate tapReceived];
}

- (void)swipeLeftReceived {
    [self.delegate swipeLeftReceived];
}

- (void)swipeRightReceived {
    [self.delegate swipeRightReceived];
}

@end
