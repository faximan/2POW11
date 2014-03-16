//
//  POWViewController.m
//  2POW11
//
//  Created by Alexander Faxå on 11/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import "POWViewController.h"

#import "POWBoard.h"
#import "POWConstants.h"
#import "POWTileView.h"

#import <LARSAdController/LARSAdController.h>

@interface POWViewController()
@property (nonatomic, strong) POWBoard *board;
@property (nonatomic) unsigned int score;
@end

@implementation POWViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.board = [[POWBoard alloc] init];
    self.bodyTileView.delegate = self;
    self.headTileView.delegate = self;
    [self newGame];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // Setup ad view controller.
    [[LARSAdController sharedManager] setPresentationType:LARSAdControllerPresentationTypeBottom];
    [[LARSAdController sharedManager] setPinningLocation:LARSAdControllerPinLocationBottom];
    [[LARSAdController sharedManager] addAdContainerToViewInViewController:self];
}

// Starts a new game
- (void)newGame {
    self.score = 0;
    [self.board resetBoard];
}

- (void)setScore:(unsigned int)score {
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"%u", self.score];
}

// Updates the body view so that it matches the current tile matrix configuration.
- (void)syncBodyViewWithBoard {
    [self.bodyTileView clearView];
    for (int c = 0; c < BOARD_WIDTH; c++) {
        for (int r = 0; r < BOARD_HEIGHT; r++) {
            unsigned int value = [self.board valueForTileAtRow:r column:c];

            // A value of 0 means no tile.
            if (value != 0) {
                [self.bodyTileView addTileWithNumber:value ToX:c y:r];
            }
        }
    }
}

#pragma mark POWTileHeadViewDelegate

- (NSArray *)illegalColumnsForValue:(unsigned int)value {
    NSMutableArray *illegalColumns = [[NSMutableArray alloc] init];
    for (int c = 0; c < BOARD_WIDTH; c++) {
        if (![self.board canPlaceTileAtColumn:c withValue:value]) {
            [illegalColumns addObject:[NSNumber numberWithInt:c]];
        }
    }
    return illegalColumns;
}


#pragma mark POWTileBodyViewDelegate

- (void)swipeLeftReceived {
    self.score += [self.board collapseTilesLeft];
    self.score += [self.board collapseTilesDownwards];

    [self.headTileView updateIllegalColumns];
    [self syncBodyViewWithBoard];
}

- (void)swipeRightReceived {
    self.score += [self.board collapseTilesRight];
    self.score += [self.board collapseTilesDownwards];

    [self.headTileView updateIllegalColumns];
    [self syncBodyViewWithBoard];
}

// Triggered when the user touches the view. Place the current tile where
// it is and create a new one.
- (void)tapReceived {
    int currentColumn = [self.headTileView currentColumn];
    // Make sure we really have a tile to drop.
    if (currentColumn < 0) {
        return;
    }

    unsigned int value = [self.headTileView currentValue];
    self.score += [self.board insertTileWithValue:value toColumn:currentColumn];

    // Is this the end?
    if ([self.board hasAvailableMoves]) {
        [self.headTileView newTile];
        [self syncBodyViewWithBoard];
    } else {
        // Restart game.
        [self newGame];
    }
}


@end
