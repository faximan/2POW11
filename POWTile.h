//
//  POWTile.h
//  2POW11
//
//  Created by Alexander Faxå on 12/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol POWTileDelegate;

@interface POWTile : NSObject

@property (nonatomic) unsigned int number;
@property (nonatomic, weak) id<POWTileDelegate> delegate;

- (id)initWithIndex:(unsigned int)index;
- (unsigned int)getIndex;

@end

@protocol POWTileDelegate <NSObject>
@required
- (void)powTileDelegate:(POWTile *)sender
  didUpdateTileToNumber:(unsigned int)number;

@end