//
//  MaroonTokenViewController.m
//  MaroonToken
//
//  Created by Mike Jablonski on 8/31/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "MaroonTokenViewController.h"

@interface MaroonTokenViewController ()

@end

@implementation MaroonTokenViewController

//------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.hostButton.layer setCornerRadius:5];
    [self.hostButton setClipsToBounds:TRUE];
    
    [self.participantButton.layer setCornerRadius:5];
    [self.participantButton setClipsToBounds:TRUE];
}

//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationItem setHidesBackButton:FALSE];
    [[UIApplication sharedApplication] setIdleTimerDisabled:FALSE];
    
}

//------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
