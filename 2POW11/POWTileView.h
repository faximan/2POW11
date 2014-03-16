//
//  POWTileView.h
//  2POW11
//
//  Created by Alexander Faxå on 12/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BOARD_HEIGHT 6
#define BOARD_WIDTH 5
#define TILE_SIZE 60

@interface POWTileView : UIView

@property (nonatomic) unsigned int tileViewNumber;

- (void)setRandomNumber;

@end
