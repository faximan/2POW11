//
//  POWTile.m
//  2POW11
//
//  Created by Alexander Faxå on 12/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import "POWTile.h"

@interface POWTile()
@property (nonatomic) unsigned int index;
@end

@implementation POWTile

- (id)initWithIndex:(unsigned int)index {
    if (self = [super init]) {
        self.index = index;
        self.number = 0;
    }
    return self;
}

- (unsigned int)getIndex {
    return _index;
}

- (void)setNumber:(unsigned int)number {
    _number = number;
    [self.delegate powTileDelegate:self didUpdateTileToNumber:number];
}

@end
