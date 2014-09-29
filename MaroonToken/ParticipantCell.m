//
//  ParticipantCell.m
//  MaroonToken
//
//  Created by Mike Jablonski on 8/30/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "ParticipantCell.h"

@implementation ParticipantCell

//------------------------------------------------------------------------------
- (void)awakeFromNib {

}

//------------------------------------------------------------------------------
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

//------------------------------------------------------------------------------
- (IBAction)endEdit:(id)sender {
    [self.participantViewController updateParticipant:self.participantTextField.text atIndexPath:self.indexPath];
}

//------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
