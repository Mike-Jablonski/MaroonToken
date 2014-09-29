//
//  OptionsCell.m
//  MaroonToken
//
//  Created by Mike Jablonski on 8/31/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "OptionsCell.h"

@implementation OptionsCell

//------------------------------------------------------------------------------
- (void)awakeFromNib {
    // Initialization code
}

//------------------------------------------------------------------------------
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

//------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

//------------------------------------------------------------------------------
- (IBAction)endEdit:(id)sender {
    [self.optionsViewController updateTextOption:self.optionTextValue.text atIndexPath:self.indexPath];
}

//------------------------------------------------------------------------------
- (IBAction)switchChanged:(id)sender {
    [self.optionsViewController updateBOOLOption:self.optionBoolValue.isOn atIndexPath:self.indexPath];
}


@end
