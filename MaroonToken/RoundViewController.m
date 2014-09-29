//
//  RoundViewController.m
//  MaroonToken
//
//  Created by Mike Jablonski on 9/4/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "RoundViewController.h"
#import "Game.h"

@interface RoundViewController ()

@property (nonatomic, strong) NSTimer* roundTimer;
@property (nonatomic, assign) NSInteger countdown;

@property (nonatomic, assign) NSInteger maxTake;
@property (nonatomic, assign) NSInteger maxGive;
@property (nonatomic, assign) BOOL takeAndGive;

@end


@implementation RoundViewController

//------------------------------------------------------------------------------
// View
//------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:TRUE];
    
    self.takeAndGive = FALSE;
    self.maxTake = 0;
    self.maxGive = 0;
    
    [self startViewingRound:[Game sharedInstance]];
}

//------------------------------------------------------------------------------
- (IBAction)submit:(id)sender {
    [self makeDecision];
}

//------------------------------------------------------------------------------
// End
//------------------------------------------------------------------------------
- (IBAction)end:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc ] initWithTitle:@"End Experiment?"
                                                    message:@"Are you sure you want to cancel and end the experiment?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes",nil];
    [alert show];
    
}

//------------------------------------------------------------------------------
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[Game sharedInstance] quitGameWithReason:QuitReasonUserQuit];
    }
}

//------------------------------------------------------------------------------
// Picker View
//------------------------------------------------------------------------------
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    if (self.takeAndGive) {
        return 2;
    }
    
    return 1;
}

//------------------------------------------------------------------------------
- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.takeAndGive) {
        switch (component) {
            case 0:
                return self.maxTake + 1;
                break;
            case 1:
                return self.maxGive + 1;
                break;
        }
    }
    
    return (self.maxGive + self.maxTake + 1);
}

//------------------------------------------------------------------------------
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%d", row];
}

//------------------------------------------------------------------------------
// Timer
//------------------------------------------------------------------------------
- (void)startRoundTimer:(NSInteger)seconds {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopRoundTimer];
        
        self.countdown = seconds;
        self.roundTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(roundTimerTicked)
                                                         userInfo:nil
                                                          repeats:YES];
    });
}

//------------------------------------------------------------------------------
- (void)roundTimerTicked {
    self.countdown -= 1;
    
    NSInteger minutes = MAX(0, self.countdown / 60);
    NSInteger seconds = MAX(0, self.countdown % 60);
    
    self.barTimerButton.title = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    
    if (self.countdown < 0) {
        [self stopRoundTimer];
        [self stopViewingRound];
    }
}

//------------------------------------------------------------------------------
- (void)stopRoundTimer {
    if (self.roundTimer != nil) {
        [self.roundTimer invalidate];
        self.roundTimer = nil;
    }
}

//------------------------------------------------------------------------------
// Game
//------------------------------------------------------------------------------
- (void)startViewingRound:(Game*)game {
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Round %d", game.roundNum+1]];
    
    [self startRoundTimer:game.round.roundTime];
    
    // Set Values
    self.roundPrivateStartingAmt.text   = game.round.privateVisible          ? [NSString stringWithFormat:@"%d", game.round.privateTokens] : @"?";
    self.roundPrivateMultiplierAmt.text = game.round.privateMultiplieVisible ? [NSString stringWithFormat:@"%.02fx", game.round.privateMultiplier] : @"?";
    self.roundGroupStartingAmt.text     = game.round.groupVisible            ? [NSString stringWithFormat:@"%d", game.round.groupTokens] : @"?";
    self.roundGroupMultiplierAmt.text   = game.round.groupMultiplierVisible  ? [NSString stringWithFormat:@"%.02fx", game.round.groupMultiplier] : @"?";
    
    self.maxGive = game.round.maxGive;
    self.maxTake = game.round.maxTake;
    
    if (self.maxTake != 0 && self.maxTake != 0) {
        self.takeAndGive = TRUE;
        self.roundPickerLeftLabel.text = @"Take From Group";
        self.roundPickerRightLabel.text = @"Give To Group";
    } else if (self.maxTake != 0) {
        self.roundPickerLeftLabel.text = @"Take From Group";
        self.roundPickerRightLabel.hidden = TRUE;
    } else if (self.maxGive != 0) {
        self.roundPickerLeftLabel.text = @"Give To Group";
        self.roundPickerRightLabel.hidden = TRUE;
    } else {
        self.roundPickerLeftLabel.text = @"No Options";
        self.roundPickerRightLabel.hidden = TRUE;
    }
    
    [self.takegiveAmountPicker reloadAllComponents];
}

//------------------------------------------------------------------------------
- (void)makeDecision {
    [self.takegiveAmountPicker setUserInteractionEnabled:FALSE];
    [self.endRoundButton setEnabled:FALSE];
    [self.endRoundButton setTitle:@"Waiting..." forState:UIControlStateDisabled];
}

//------------------------------------------------------------------------------
- (void)stopViewingRound {
    [self makeDecision];
    
    NSInteger takingTokens = 0;
    NSInteger givingTokens = 0;
    
    if (self.maxTake != 0 && self.maxTake != 0) {
        takingTokens = [self.takegiveAmountPicker selectedRowInComponent:0];
        givingTokens = [self.takegiveAmountPicker selectedRowInComponent:1];
    } else if (self.maxTake != 0) {
        takingTokens = [self.takegiveAmountPicker selectedRowInComponent:0];
    } else if (self.maxGive != 0) {
        givingTokens = [self.takegiveAmountPicker selectedRowInComponent:0];
    }
    
    [[Game sharedInstance] endRoundClientWithTakeGive:takingTokens gives:givingTokens];
}

@end
