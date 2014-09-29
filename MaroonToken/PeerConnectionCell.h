//
//  PeerConnectionCell.h
//  MaroonToken
//
//  Created by Mike Jablonski on 8/31/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeerConnectionCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* peerLabel;
@property (nonatomic, weak) IBOutlet UILabel* checkmarkLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* activityIndicator;

@end
