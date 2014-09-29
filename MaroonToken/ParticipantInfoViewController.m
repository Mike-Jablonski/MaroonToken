//
//  ParticipantInfoViewController.m
//  MaroonToken
//
//  Created by Mike Jablonski on 9/1/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "ParticipantInfoViewController.h"
#import "ParticipantInfoCell.h"
#import "Options.h"

@interface ParticipantInfoViewController ()

@property (nonatomic, strong) NSMutableArray* participantInfos;
@property (nonatomic, assign) BOOL isKeyboardObserver;

@end


@implementation ParticipantInfoViewController

//------------------------------------------------------------------------------
// View
//------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _participantInfos = [[NSMutableArray alloc] init];
        _isKeyboardObserver = FALSE;
    }
    
    return self;
}

//------------------------------------------------------------------------------
- (void)dealloc {
    if (self.isKeyboardObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}

//------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ParticipantInfoCell" bundle:nil] forCellReuseIdentifier:@"ParticipantInfoCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.isKeyboardObserver = TRUE;
}

//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:FALSE];
    
}

//------------------------------------------------------------------------------
- (void)showInvalidAlert {
    UIAlertView* alert = [[UIAlertView alloc ] initWithTitle:@"Participant Invalid"
                                                     message:@"Participant must have non-blank ID."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];
}

//------------------------------------------------------------------------------
// Actions
//------------------------------------------------------------------------------
- (IBAction)next:(id)sender {
    ParticipantInfoCell* cell = (ParticipantInfoCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (cell.infoTextValue.text.length) {
        [Options setParticipantID:cell.infoTextValue.text];
        [self performSegueWithIdentifier:@"toHostConnection" sender:sender];
    } else {
        [self showInvalidAlert];
    }
}

//------------------------------------------------------------------------------
// TableView
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParticipantInfoCell* cell = (ParticipantInfoCell*)[tableView dequeueReusableCellWithIdentifier:@"ParticipantInfoCell"];
    [cell.infoLabel setText:@"ID"];
    [cell.infoTextValue setPlaceholder:@"Participant ID"];
    
    return cell;
}

//------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"PARTICIPANT INFO";
}

//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return 1;
}

//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

//------------------------------------------------------------------------------
// Keyboard
//------------------------------------------------------------------------------
- (void)keyboardWillShow:(NSNotification *)notification {
    // Device Info
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    // Keyboard Info
    NSDictionary* info = [notification userInfo];
    NSValue* kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat height = isPortrait ? keyboardFrame.size.height : keyboardFrame.size.width;
    
    // Animate
    self.keyboardHeightConstraint.constant = height;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

//------------------------------------------------------------------------------
- (void)keyboardWillHide:(NSNotification *)notification {
    // Keyboard Info
    NSDictionary* info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // Animate
    self.keyboardHeightConstraint.constant = 0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
