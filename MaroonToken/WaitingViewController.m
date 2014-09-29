//
//  WaitingViewController.m
//  MaroonToken
//
//  Created by Mike Jablonski on 9/13/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "WaitingViewController.h"
#import "Game.h"

@interface WaitingViewController ()

@end


@implementation WaitingViewController

//------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:TRUE];
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
        [[Game sharedInstance] quitGameWithReason:QuitReasonServerQuit];
    }
}

@end
