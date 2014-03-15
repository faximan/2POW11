//
//  POWViewController.h
//  2POW11
//
//  Created by Alexander Faxå on 11/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "POWTileHeadView.h"
#import "POWTileBodyView.h"

@interface POWViewController : UIViewController <POWTileBodyViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;
@property (nonatomic, weak) IBOutlet POWTileHeadView *headTileView;
@property (nonatomic, weak) IBOutlet POWTileBodyView *bodyTileView;

@end

