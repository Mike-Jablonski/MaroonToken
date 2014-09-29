//
//  ResultViewController.m
//  MaroonToken
//
//  Created by Mike Jablonski on 9/3/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "ResultViewController.h"
#import "MainNavigationViewController.h"
#import "Game.h"
#import "Player.h"

@interface ResultViewController ()

@property (nonatomic, weak) Player* player;

@property (nonatomic, strong) NSTimer* resultTimer;
@property (nonatomic, assign) NSInteger countdown;

@end


@implementation ResultViewController

//------------------------------------------------------------------------------
// View
//------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:TRUE];
    
    MainNavigationViewController* mainNav = (MainNavigationViewController*)self.navigationController;
    _player = mainNav.player;
    
    [self startViewingResults:[Game sharedInstance] myPlayer:self.player];
}

//------------------------------------------------------------------------------
// End
//------------------------------------------------------------------------------
- (IBAction)end:(id)sender {
    if ([Game sharedInstance].isFinished) {
        [[Game sharedInstance] quitGameWithReason:QuitReasonUserQuit];
        [self.navigationController popToRootViewControllerAnimated:TRUE];
    } else {
        UIAlertView* alert = [[UIAlertView alloc ] initWithTitle:@"End Experiment?"
                                                         message:@"Are you sure you want to cancel and end the experiment?"
                                                        delegate:self
                                               cancelButtonTitle:@"No"
                                               otherButtonTitles:@"Yes",nil];
        [alert show];
    }
}

//------------------------------------------------------------------------------
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[Game sharedInstance] quitGameWithReason:QuitReasonUserQuit];
    }
}


//------------------------------------------------------------------------------
// Timer
//------------------------------------------------------------------------------
- (void)startResultTimer:(NSInteger)seconds {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopResultTimer];
        
        self.countdown = seconds;
        self.resultTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(resultTimerTicked)
                                                         userInfo:nil
                                                          repeats:YES];
    });
}

//------------------------------------------------------------------------------
- (void)resultTimerTicked {
    self.countdown -= 1;
    
    NSInteger minutes = MAX(0, self.countdown / 60);
    NSInteger seconds = MAX(0, self.countdown % 60);
    
    self.barTimerButton.title = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    
    if (self.countdown < 0) {
        [self stopResultTimer];
        
        if ([Game sharedInstance].roundNum + 1 < [Game sharedInstance].round.numOfRounds) {
            [self stopViewingResults];
        } else {
            [self.endButton setTitle:@"Exit"];
        }
    }
}

//------------------------------------------------------------------------------
- (void)stopResultTimer {
    if (self.resultTimer != nil) {
        [self.resultTimer invalidate];
        self.resultTimer = nil;
    }
}


//------------------------------------------------------------------------------
// Game
//------------------------------------------------------------------------------
- (void)startViewingResults:(Game *)game myPlayer:(Player *)myplayer {
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Round %d Results", game.roundNum+1]];
    
    [self startResultTimer:game.round.resultTime];
    
    NSInteger nonMultiPrivate = [[myplayer.roundPrivateTokens lastObject] integerValue];
    NSInteger nonMultiGroup   = [[myplayer.roundGroupTokens lastObject] integerValue];
    
    NSInteger privateToFromGroup = [[myplayer.roundTakeTokens lastObject] integerValue] - [[myplayer.roundGiveTokens lastObject] integerValue];
    NSInteger othersToFromGroup  = nonMultiGroup - game.round.groupTokens + privateToFromGroup; //+ sign is correct.
    
    NSInteger multiPrivate = nonMultiPrivate * game.round.privateMultiplier;
    NSInteger multiGroup = nonMultiGroup * game.round.groupMultiplier;
    
    NSInteger multiGroupShare = multiGroup/(myplayer.groupSize);
    
    [myplayer.roundPrivateTokens replaceObjectAtIndex:game.roundNum withObject:[NSNumber numberWithInteger:multiPrivate]];
    [myplayer.roundGroupTokens replaceObjectAtIndex:game.roundNum withObject:[NSNumber numberWithInteger:multiGroup]];
    
    float multiPrivateMoney = multiPrivate * (game.round.tokenToCents/ 100.0); // Keep as dollars
    float multiGroupShareMoney = multiGroupShare * (game.round.tokenToCents / 100.0); // Keep as dollars
    float roundEarnings = multiPrivateMoney + multiGroupShareMoney;
    
    [myplayer.roundEarningsTokens addObject:[NSNumber numberWithFloat:roundEarnings]];
    
    float totalEarnings = 0.0;
    for (NSNumber* n in myplayer.roundEarningsTokens) {
        totalEarnings += [n floatValue];
    }
    
    // Private
    self.resultsPrivateAmt.text         = [NSString stringWithFormat:@"%d", multiPrivate];
    self.resultsPrivateStartingAmt.text = game.round.privateVisible ? [NSString stringWithFormat:@"%d", game.round.privateTokens] : @"?";
    
    if (privateToFromGroup > 0) {
        self.resultsPrivateGroup.text    = @"Taken From Group:";
        self.resultsPrivateGroupAmt.text = [NSString stringWithFormat:@"+ %d", privateToFromGroup];
    } else if (privateToFromGroup < 0) {
        self.resultsPrivateGroup.text    = @"Given To Group:";
        self.resultsPrivateGroupAmt.text = [NSString stringWithFormat:@"- %d", abs(privateToFromGroup)];
    } else {
        if (game.round.maxTake != 0 && game.round.maxTake != 0) {
            self.resultsPrivateGroup.text    = @"To/From Group:";
            self.resultsPrivateGroupAmt.text = @"-/+ 0";
        } else if (game.round.maxTake != 0) {
            self.resultsPrivateGroup.text    = @"Taken From Group:";
            self.resultsPrivateGroupAmt.text = @"+ 0";
        } else if (game.round.maxGive != 0) {
            self.resultsPrivateGroup.text    = @"Given To Group:";
            self.resultsPrivateGroupAmt.text = @"- 0";
        }
    }
    
    self.resultsPrivateTotalAmt.text = [NSString stringWithFormat:@"%d", nonMultiPrivate];
    
    if (game.round.privateMultiplieVisible) {
        self.resultsPrivateMultiplier.text = [NSString stringWithFormat:@"(%.02fx)", game.round.privateMultiplier];
    } else {
        self.resultsPrivateMultiplier.text = @"(?x)";
    }
    
    // Group
    self.resultsGroupAmt.text         = [NSString stringWithFormat:@"%d", multiGroupShare];
    self.resultsGroupSharesAmt.text   = [NSString stringWithFormat:@"(Your Share Of %d)", multiGroup];
    self.resultsGroupStartingAmt.text = game.round.groupVisible ? [NSString stringWithFormat:@"%d", game.round.groupTokens] : @"?";
    
    if (privateToFromGroup > 0) {
        self.resultsGroupYou.text    = @"Taken By You:";
        self.resultsGroupYouAmt.text = [NSString stringWithFormat:@"- %d", privateToFromGroup];
    } else if (privateToFromGroup < 0) {
        self.resultsGroupYou.text    = @"Given By You:";
        self.resultsGroupYouAmt.text = [NSString stringWithFormat:@"+ %d", abs(privateToFromGroup)];
    } else {
        if (game.round.maxTake != 0 && game.round.maxTake != 0) {
            self.resultsGroupYou.text = @"Taken/Given By You:";
            self.resultsGroupYouAmt.text = @"-/+ 0";
        } else if (game.round.maxTake != 0) {
            self.resultsGroupYou.text = @"Taken By You:";
            self.resultsGroupYouAmt.text = @"- 0";
        } else if (game.round.maxGive != 0) {
            self.resultsGroupYou.text = @"Given By You:";
            self.resultsGroupYouAmt.text = @"+ 0";
        }
    }
    
    if (othersToFromGroup > 0) {
        self.resultsGroupOthers.text = @"Given By Others:";
        if (game.round.maxTake != 0 && game.round.maxTake != 0) {
            self.resultsGroupOthers.text = @"Net Given By Others:";
        }
        self.resultsGroupOthersAmt.text = [NSString stringWithFormat:@"+ %d", othersToFromGroup];
    } else if (othersToFromGroup < 0) {
        self.resultsGroupOthers.text = @"Taken By Others:";
        if (game.round.maxTake != 0 && game.round.maxTake != 0) {
            self.resultsGroupOthers.text = @"Net Taken By Others:";
        }
        self.resultsGroupOthersAmt.text = [NSString stringWithFormat:@"- %d", abs(othersToFromGroup)];
    } else {
        if (game.round.maxTake != 0 && game.round.maxTake != 0) {
            self.resultsGroupOthers.text    = @"Taken/Given By Others:";
            self.resultsGroupOthersAmt.text = @"-/+ 0";
        } else if (game.round.maxTake != 0) {
            self.resultsGroupOthers.text    = @"Taken By Others:";
            self.resultsGroupOthersAmt.text = @"- 0";
        } else if (game.round.maxGive != 0) {
            self.resultsGroupOthers.text    = @"Given By Others:";
            self.resultsGroupOthersAmt.text = @"+ 0";
        }
    }
    
    self.resultsGroupTotalAmt.text = [NSString stringWithFormat:@"%d",nonMultiGroup];
    if (game.round.groupMultiplierVisible) {
        self.resultsGroupMultiplier.text = [NSString stringWithFormat:@"(%.02fx)", game.round.groupMultiplier];
    } else {
        self.resultsGroupMultiplier.text = @"(?x)";
    }
    
    // Earnings
    self.resultsRoundEarningsAmt.text        = [NSString stringWithFormat:@"$%.02f", roundEarnings];
    self.resultsRoundEarningsPrivateAmt.text = [NSString stringWithFormat:@"$%.02f", multiPrivateMoney];
    self.resultsRoundEarningsGroupAmt.text   = [NSString stringWithFormat:@"+ $%.02f", multiGroupShareMoney];
    self.resultsRoundEarningsTotalAmt.text   = [NSString stringWithFormat:@"$%.02f", roundEarnings];
    self.resultsRoundEarningsMultiplier.text = [NSString stringWithFormat:@"(%.02f¢ / token) ", game.round.tokenToCents];
    
    self.resultsTotalEarningsAmt.text = [NSString stringWithFormat:@"$%.02f", totalEarnings];
}

//------------------------------------------------------------------------------
- (void)stopViewingResults {
    [[Game sharedInstance] endResultsClient];
}

@end
