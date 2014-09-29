//
//  ParticipantsConnectionViewController.h
//  MaroonToken
//
//  Created by Mike Jablonski on 9/2/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchmakingServer.h"

@interface ParticipantsConnectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MatchmakingServerDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* startButton;

- (IBAction)start:(id)sender;
- (IBAction)end:(id)sender;

@end
