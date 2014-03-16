//
//  POWTileBodyView.m
//  2POW11
//
//  Created by Alexander Faxå on 15/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import "POWTileBodyView.h"

#import "POWConstants.h"
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

- (void)addTile:(POWTile *)tile toRow:(unsigned int)r column:(unsigned int)c {
    unsigned int tileX = c * TILE_SIZE;
    unsigned int tileY = (self.frame.size.height - TILE_SIZE) -  r * TILE_SIZE;
    NSAssert(tileX + TILE_SIZE <= self.frame.size.width, @"Illegal width");
    NSAssert(tileY + TILE_SIZE <= self.frame.size.height, @"Illegal height");

    POWTileView *newTileView = [[POWTileView alloc]
                                initWithFrame:CGRectMake(tileX, tileY, TILE_SIZE, TILE_SIZE)];
    newTileView.tile = tile;
    [self addSubview:newTileView];
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
