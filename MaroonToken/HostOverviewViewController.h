//
//  HostOverviewViewController.h
//  MaroonToken
//
//  Created by Mike Jablonski on 9/9/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface HostOverviewViewController : UIViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel* timeLabel;
@property (nonatomic, weak) IBOutlet UILabel* stateLabel;
@property (nonatomic, weak) IBOutlet UILabel* roundNumberLabel;
@property (nonatomic, weak) IBOutlet UIProgressView* progressView;

@property (nonatomic, weak) IBOutlet UILabel* emailCheckmark;
@property (nonatomic, weak) IBOutlet UIButton* emailButton;

@property (nonatomic, weak) IBOutlet UIBarButtonItem* endButton;

- (IBAction)mailResults:(id)sender;
- (IBAction)end:(id)sender;

@end
