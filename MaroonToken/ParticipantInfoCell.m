//
//  ParticipantInfoCell.m
//  MaroonToken
//
//  Created by Mike Jablonski on 8/31/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "ParticipantInfoCell.h"

@implementation ParticipantInfoCell

//------------------------------------------------------------------------------
- (void)awakeFromNib {
    // Initialization code
}

//------------------------------------------------------------------------------
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

//------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
