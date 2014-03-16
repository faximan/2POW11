//
//  POWTileView.m
//  2POW11
//
//  Created by Alexander Faxå on 12/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import "POWTileView.h"

#import "POWColorPicker.h"

@interface POWTileView()
@property (nonatomic, strong) UILabel *numberLabel;
@end

@implementation POWTileView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.numberLabel = [[UILabel alloc]
                            initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.numberLabel.font = [self.numberLabel.font fontWithSize:25];
        [self addSubview:self.numberLabel];
    }
    return self;
}

- (void)setTile:(POWTile *)tile {
    _tile = tile;
    switch (tile.type) {
        case kPOWTileTypeRegular:
            self.numberLabel.text = [NSString stringWithFormat:@"%u", tile.value];
            self.backgroundColor = [POWColorPicker colorForNumber:tile.value];
            break;
        case kPowTileTypeBlock:
            self.backgroundColor = [UIColor blackColor];
            self.numberLabel.text = @"";
            break;
        case kPowTileTypeBeam:
            self.backgroundColor = [UIColor redColor];
            self.numberLabel.text = @"";
            break;
        default:
            NSAssert(0, @"Illegal enum");
            break;
    }


}

@end
