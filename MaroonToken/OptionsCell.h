//
//  OptionsCell.h
//  MaroonToken
//
//  Created by Mike Jablonski on 8/31/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionsViewController.h"

@interface OptionsCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel* optionLabel;
@property (nonatomic, weak) IBOutlet UISwitch* optionBoolValue;
@property (nonatomic, weak) IBOutlet UITextField* optionTextValue;

@property (nonatomic, weak) OptionsViewController* optionsViewController;
@property (nonatomic, strong) NSIndexPath* indexPath;

- (IBAction)endEdit:(id)sender;
- (IBAction)switchChanged:(id)sender;

@end
