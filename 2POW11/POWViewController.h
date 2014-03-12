//
//  POWViewController.h
//  2POW11
//
//  Created by Alexander Faxå on 11/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "POWTileView.h"

@interface POWViewController : UIViewController

@property (nonatomic, strong) IBOutletCollection(POWTileView) NSArray *tilesViews;

- (IBAction)left;
- (IBAction)right;
- (IBAction)up;
- (IBAction)down;

@end

