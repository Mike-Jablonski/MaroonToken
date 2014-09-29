//
//  OptionsViewController.h
//  MaroonToken
//
//  Created by Mike Jablonski on 8/31/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* nextButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* keyboardHeightConstraint;

- (IBAction)next:(id)sender;
- (void)updateBOOLOption:(BOOL)value atIndexPath:(NSIndexPath*)indexPath;
- (void)updateTextOption:(NSString*)value atIndexPath:(NSIndexPath*)indexPath;

@end
