//
//  ParticipantCell.h
//  MaroonToken
//
//  Created by Mike Jablonski on 8/30/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddParticipantsViewController.h"

@interface ParticipantCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel* participantLabel;
@property (nonatomic, weak) IBOutlet UITextField* participantTextField;

@property (nonatomic, weak) AddParticipantsViewController* participantViewController;
@property (nonatomic, strong) NSIndexPath* indexPath;

- (IBAction)endEdit:(id)sender;

@end
