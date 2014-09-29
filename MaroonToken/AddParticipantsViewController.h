//
//  AddParticipantsViewController.h
//  MaroonToken
//
//  Created by Mike Jablonski on 8/11/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddParticipantsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* nextButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* addButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* keyboardHeightConstraint;

- (IBAction)next:(id)sender;
- (IBAction)addParticipant:(id)sender;
- (void)updateParticipant:(NSString*)name atIndexPath:(NSIndexPath*)indexPath;

@end
