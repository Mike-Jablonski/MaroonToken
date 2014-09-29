//
//  HostConnectionViewController.h
//  MaroonToken
//
//  Created by Mike Jablonski on 9/2/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchmakingClient.h"

@interface HostConnectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MatchmakingClientDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@end
