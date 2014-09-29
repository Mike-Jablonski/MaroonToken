//
//  HostOverviewViewController.m
//  MaroonToken
//
//  Created by Mike Jablonski on 9/9/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "HostOverviewViewController.h"
#import "MainNavigationViewController.h"
#import "Game.h"
#import "Player.h"

@interface HostOverviewViewController ()

@property (nonatomic, weak) Player* player;

@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, assign) NSInteger countdown;

@property (nonatomic, assign) NSInteger totalElapsedSeconds;

@end


@implementation HostOverviewViewController

//------------------------------------------------------------------------------
// View
//------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:TRUE];
    
    MainNavigationViewController* mainNav = (MainNavigationViewController*)self.navigationController;
    
    self.player = mainNav.player;
    self.totalElapsedSeconds = 0;
    
    [[Game sharedInstance] addObserver:self
           forKeyPath:@"state"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
              context:NULL];
    
    [[Game sharedInstance] addObserver:self
           forKeyPath:@"roundNum"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
              context:NULL];

}

//------------------------------------------------------------------------------
- (void)dealloc {
    [[Game sharedInstance] removeObserver:self forKeyPath:@"state"];
    [[Game sharedInstance] removeObserver:self forKeyPath:@"roundNum"];
}

//------------------------------------------------------------------------------
- (void)observeValueForKeyPath:(NSString*)path ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if ([path isEqualToString:@"state"]) {
        if ([Game sharedInstance].state == GameStateInRound) {
            [self.stateLabel setText:@"Round"];
            [self startTimer:[Game sharedInstance].round.roundTime];
        } else if ([Game sharedInstance].state == GameStateInResults) {
            [self.stateLabel setText:@"Results"];
            [self startTimer:[Game sharedInstance].round.resultTime];
            
            if ([Game sharedInstance].roundNum == [Game sharedInstance].round.numOfRounds) {
                [self.emailButton setHidden:FALSE];
                [self.endButton setTitle:@"Exit"];
            }
        } else {
            [self.stateLabel setText:@""];
        }
    } else if ([path isEqualToString:@"roundNum"]) {
        [self.roundNumberLabel setText:[NSString stringWithFormat:@"Round %d of %d", [Game sharedInstance].roundNum, [Game sharedInstance].round.numOfRounds]];
    }
}

//------------------------------------------------------------------------------
- (void)updateProgress {
    NSUInteger totalSeconds =
    ([Game sharedInstance].round.numOfRounds * [Game sharedInstance].round.roundTime)
    + ([Game sharedInstance].round.numOfRounds * [Game sharedInstance].round.resultTime);
    
    [self.progressView setProgress:((float)self.totalElapsedSeconds/(float)totalSeconds) animated:TRUE];
}

//------------------------------------------------------------------------------
// End
//------------------------------------------------------------------------------
- (IBAction)end:(id)sender {
    if ([Game sharedInstance].isFinished) {
        [[Game sharedInstance] quitGameWithReason:QuitReasonServerQuit];
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
        [[Game sharedInstance] quitGameWithReason:QuitReasonServerQuit];
    }
}

//------------------------------------------------------------------------------
// Timer
//------------------------------------------------------------------------------
- (void)startTimer:(NSInteger)seconds {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopTimer];
        
        self.countdown = seconds;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(timerTicked)
                                                         userInfo:nil
                                                          repeats:YES];
    });
}

//------------------------------------------------------------------------------
- (void)timerTicked {
    self.countdown -= 1;
    self.totalElapsedSeconds += 1;
    
    NSInteger minutes = MAX(0, self.countdown / 60);
    NSInteger seconds = MAX(0, self.countdown % 60);
    
    self.timeLabel.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    
    if (self.countdown < 0) {
        [self stopTimer];
    }
    
    [self updateProgress];
}

//------------------------------------------------------------------------------
- (void)stopTimer {
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

//------------------------------------------------------------------------------
// Mail
//------------------------------------------------------------------------------
- (IBAction)mailResults:(id)sender {
    NSString* titleString = [NSString stringWithFormat:@"%@\n", [Game sharedInstance].round.experimentName];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd yyyy hh:mm a"];
    NSString* subtitleString = [NSString stringWithFormat:@"\nDate:, %@\n\n", [dateFormatter stringFromDate:[NSDate date]]];
    
    NSString* roundString = [NSString stringWithFormat:@"\nInitial Group Tokens:, %d \n Initial Private Tokens:, %d \n Group Multiplier:, %.02f \n Private Multiplier:, %.02f \n Initial Group Tokens Hidden:, %@ \n Initial Private Tokens Hidden:, %@ \n Group Multiplier Hidden:, %@ \n Private Multiplier Hidden:, %@ \n Max Give To Group:, %d \n Max Take From Group:, %d \n Round Time (seconds):, %d \n Result Time (seconds):, %d \n Token Value (cents):, %.02f \n Number of Rounds:, %d \n", [Game sharedInstance].round.groupTokens, [Game sharedInstance].round.privateTokens, [Game sharedInstance].round.groupMultiplier, [Game sharedInstance].round.privateMultiplier, [Game sharedInstance].round.groupVisible ? @"Visible" : @"Hidden", [Game sharedInstance].round.privateVisible ? @"Visible" : @"Hidden", [Game sharedInstance].round.groupMultiplierVisible ? @"Visible" : @"Hidden", [Game sharedInstance].round.privateMultiplieVisible ? @"Visible" : @"Hidden", [Game sharedInstance].round.maxGive, [Game sharedInstance].round.maxTake, [Game sharedInstance].round.roundTime, [Game sharedInstance].round.resultTime, [Game sharedInstance].round.tokenToCents, [Game sharedInstance].round.numOfRounds];
    
    NSString* playersString = @"\nParticipant ID, Group Size, Round, Taken From Group, Given To Group\n\n";
    
    for (NSString* peerID in [Game sharedInstance].players) {
        Player* player = [[Game sharedInstance] playerWithPeerID:peerID];
        for (int r = 0; r<[player.roundTakeTokens count]; r++) {
            playersString = [NSString stringWithFormat:@"\n%@ %@,%d,%d,%d,%d\n", playersString, player.name, player.groupSize, (r + 1), [[player.roundTakeTokens objectAtIndex:r] intValue], [[player.roundGiveTokens objectAtIndex:r] intValue]];
        }
    }
    
    NSString* finalMailString = [NSString stringWithFormat:@"%@,%@,%@,%@", titleString, subtitleString, roundString, playersString];
    NSData* csvFileContentsData = [finalMailString dataUsingEncoding:NSASCIIStringEncoding];
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:[NSString stringWithFormat:@"[MaroonToken] %@ Data", [Game sharedInstance].round.experimentName]];
        
        NSString* emailBody = [Game sharedInstance].round.experimentName;
        [mailer setMessageBody:emailBody isHTML:NO];
        
        [mailer addAttachmentData:csvFileContentsData mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"%@Data.csv", [Game sharedInstance].round.experimentName]];
        
        [self presentViewController:mailer animated:YES completion:NULL];

    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Mail Failure"
                                                        message:@"Cannot email report. No mail account setup on this device."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

//------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            [self.emailCheckmark setHidden:FALSE];
            break;
        case MFMailComposeResultSent:
            [self.emailCheckmark setHidden:FALSE];
            break;
        case MFMailComposeResultFailed:
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Mail Failure"
                                                            message:@"Emailing report failed. Please try again."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            
             [alert show];
        }
            break;
        default:
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Mail Failure"
                                                            message:@"Emailing report encountered a problem. Please try again."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            
            [alert show];
        }
            break;
    }

    [self dismissViewControllerAnimated:TRUE completion:NULL];
}

@end
