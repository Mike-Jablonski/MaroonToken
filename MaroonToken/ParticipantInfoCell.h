//
//  ParticipantInfoCell.h
//  MaroonToken
//
//  Created by Mike Jablonski on 8/31/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionsViewController.h"

@interface ParticipantInfoCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel* infoLabel;
@property (nonatomic, weak) IBOutlet UITextField* infoTextValue;

@end
