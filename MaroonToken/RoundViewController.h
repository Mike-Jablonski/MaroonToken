//
//  RoundViewController.h
//  MaroonToken
//
//  Created by Mike Jablonski on 9/4/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoundViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel* roundPrivateStarting;
@property (nonatomic, weak) IBOutlet UILabel* roundPrivateStartingAmt;
@property (nonatomic, weak) IBOutlet UILabel* roundPrivateMultiplier;
@property (nonatomic, weak) IBOutlet UILabel* roundPrivateMultiplierAmt;
@property (nonatomic, weak) IBOutlet UILabel* roundGroupStarting;
@property (nonatomic, weak) IBOutlet UILabel* roundGroupStartingAmt;
@property (nonatomic, weak) IBOutlet UILabel* roundGroupMultiplier;
@property (nonatomic, weak) IBOutlet UILabel* roundGroupMultiplierAmt;

@property (nonatomic, weak) IBOutlet UILabel* roundPickerLeftLabel;
@property (nonatomic, weak) IBOutlet UILabel* roundPickerRightLabel;

@property (nonatomic, weak) IBOutlet UIPickerView* takegiveAmountPicker;

@property (nonatomic, weak) IBOutlet UIButton* endRoundButton;

@property (nonatomic, weak) IBOutlet UIBarButtonItem* barTimerButton;

- (IBAction)submit:(id)sender;

@end
