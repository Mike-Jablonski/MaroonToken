//
//  ResultViewController.h
//  MaroonToken
//
//  Created by Mike Jablonski on 9/3/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel* resultsPrivateAmt;
@property (nonatomic, weak) IBOutlet UILabel* resultsPrivateStarting;
@property (nonatomic, weak) IBOutlet UILabel* resultsPrivateStartingAmt;
@property (nonatomic, weak) IBOutlet UILabel* resultsPrivateGroup;
@property (nonatomic, weak) IBOutlet UILabel* resultsPrivateGroupAmt;
@property (nonatomic, weak) IBOutlet UILabel* resultsPrivateTotalAmt;
@property (nonatomic, weak) IBOutlet UILabel* resultsPrivateMultiplier;

@property (nonatomic, weak) IBOutlet UILabel* resultsGroupAmt;
@property (nonatomic, weak) IBOutlet UILabel* resultsGroupSharesAmt;
@property (nonatomic, weak) IBOutlet UILabel* resultsGroupStarting;
@property (nonatomic, weak) IBOutlet UILabel* resultsGroupStartingAmt;
@property (nonatomic, weak) IBOutlet UILabel* resultsGroupYou;
@property (nonatomic, weak) IBOutlet UILabel* resultsGroupYouAmt;
@property (nonatomic, weak) IBOutlet UILabel* resultsGroupOthers;
@property (nonatomic, weak) IBOutlet UILabel* resultsGroupOthersAmt;
@property (nonatomic, weak) IBOutlet UILabel* resultsGroupTotalAmt;
@property (nonatomic, weak) IBOutlet UILabel* resultsGroupMultiplier;

@property (nonatomic, weak) IBOutlet UILabel* resultsRoundEarningsAmt;
@property (nonatomic, weak) IBOutlet UILabel* resultsRoundEarningsPrivate;
@property (nonatomic, weak) IBOutlet UILabel* resultsRoundEarningsPrivateAmt;
@property (nonatomic, weak) IBOutlet UILabel* resultsRoundEarningsGroup;
@property (nonatomic, weak) IBOutlet UILabel* resultsRoundEarningsGroupAmt;
@property (nonatomic, weak) IBOutlet UILabel* resultsRoundEarningsTotalAmt;
@property (nonatomic, weak) IBOutlet UILabel* resultsRoundEarningsMultiplier;

@property (nonatomic, weak) IBOutlet UILabel* resultsTotalEarningsAmt;

@property (nonatomic, weak) IBOutlet UIBarButtonItem* barTimerButton;

@property (nonatomic, weak) IBOutlet UIBarButtonItem* endButton;

- (IBAction)end:(id)sender;

@end
