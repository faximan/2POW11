//
//  POWTileBodyView.h
//  2POW11
//
//  Created by Alexander Faxå on 15/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "POWTile.h"

@protocol POWTileBodyViewDelegate;

@interface POWTileBodyView : UIView

@property (nonatomic, weak) id<POWTileBodyViewDelegate> delegate;

- (void)clearView;
- (void)addTile:(POWTile *)tile toRow:(unsigned int)r column:(unsigned int)c;

@end


@protocol POWTileBodyViewDelegate <NSObject>
- (void)swipeLeftReceived;
- (void)swipeRightReceived;
- (void)tapReceived;

@end