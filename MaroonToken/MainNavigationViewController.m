//
//  MainNavigationViewController.m
//  MaroonToken
//
//  Created by Mike Jablonski on 9/4/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "MainNavigationViewController.h"
#import "HostConnectionViewController.h"
#import "ParticipantsConnectionViewController.h"

@interface MainNavigationViewController ()

@end


@implementation MainNavigationViewController

//------------------------------------------------------------------------------
// View
//------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [Game sharedInstance].delegate = self;
    }
    
    return self;
}

//------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
}

//------------------------------------------------------------------------------
- (void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [[Game sharedInstance] quitGameWithReason:QuitReasonUserQuit];
    } else {
        [super pushViewController:viewController animated:animated];
    }
}

//------------------------------------------------------------------------------
// Game
//------------------------------------------------------------------------------
- (void)gameWaitingForClientsReady:(Game*)game {
    
}

//------------------------------------------------------------------------------
- (void)gameWaitingForServerReady:(Game*)game {
    UIViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ClientWaitingView"];
    [self pushViewController:viewController animated:TRUE];
}

//------------------------------------------------------------------------------
- (void)startViewingResults:(Game*)game myPlayer:(Player*)myplayer {
    self.player = myplayer;
    
    if (!game.isServer) {
        UIViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ResultView"];
        [self pushViewController:viewController animated:TRUE];
    }
}

//------------------------------------------------------------------------------
- (void)stopViewingResults:(Game*)game {
    
}

//------------------------------------------------------------------------------
- (void)startViewingRound:(Game*)game {
    if (!game.isServer) {
        UIViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RoundView"];
        [self pushViewController:viewController animated:TRUE];
    }
}

//------------------------------------------------------------------------------
- (void)stopViewingRound:(Game*)game {
    
}

//------------------------------------------------------------------------------
- (void)game:(Game*)game didQuitWithReason:(QuitReason)reason {
    if (game.isFinished) {
        return;
    }
    
    UIAlertView* alert = [[UIAlertView alloc ] initWithTitle:@"Experiment Ended"
                                                     message:@"Experiment was cancelled or ended prematurely because of connection issues."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
    [alert show];
    
    for (id viewController in self.viewControllers) {
        if ([viewController isKindOfClass:[HostConnectionViewController class]]) {
            [self popToViewController:viewController animated:TRUE];
            return;
        }
        
        if ([viewController isKindOfClass:[ParticipantsConnectionViewController class]]) {
            [self popToViewController:viewController animated:TRUE];
            return;
        }
    }
}

@end
