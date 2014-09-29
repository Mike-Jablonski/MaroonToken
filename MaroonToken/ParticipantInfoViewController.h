//
//  ParticipantInfoViewController.h
//  MaroonToken
//
//  Created by Mike Jablonski on 9/1/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParticipantInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* nextButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* keyboardHeightConstraint;

- (IBAction)next:(id)sender;

@end
