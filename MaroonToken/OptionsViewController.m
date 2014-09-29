//
//  OptionsViewController.m
//  MaroonToken
//
//  Created by Mike Jablonski on 8/31/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "OptionsViewController.h"
#import "OptionsCell.h"
#import "Options.h"

@interface OptionsViewController ()

@property (nonatomic, strong) NSMutableArray* optionsList;
@property (nonatomic, strong) NSMutableSet* indexesInError;
@property (nonatomic, strong) UIGestureRecognizer* tapGesture;
@property (nonatomic, assign) BOOL isKeyboardObserver;

@end


@implementation OptionsViewController

//------------------------------------------------------------------------------
// View
//------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _indexesInError = [[NSMutableSet alloc] init];
        _isKeyboardObserver = FALSE;
        
        _optionsList = [@[@{@"sectionTitle" : @"Experiment",
                            @"sectionOptions" : @[@{@"optionTitle" : @"ID", @"optionType" : @"string", @"optionKey" : EXPERIMENT_ID}]},
                          @{@"sectionTitle" : @"Initial Tokens",
                            @"sectionFooter" : @"At the start of each round, each participant will begin with the above initial private tokens and the group begins with the above groups tokens. You may hide these amounts from the participants.",
                            @"sectionOptions" : @[@{@"optionTitle" : @"Private Tokens", @"optionType" : @"integer", @"optionKey" : TOKEN_PRIVATE_INITIAL},
                                                  @{@"optionTitle" : @"Private Tokens Visible", @"optionType" : @"bool", @"optionKey" : TOKEN_PRIVATE_VISIBLE},
                                                  @{@"optionTitle" : @"Group Tokens", @"optionType" : @"integer", @"optionKey" : TOKEN_GROUP_INITIAL},
                                                  @{@"optionTitle" : @"Group Tokens Visible", @"optionType" : @"bool", @"optionKey" : TOKEN_GROUP_VISIBLE}]},
                          @{@"sectionTitle" : @"Multipliers",
                            @"sectionFooter" : @"At the end of each round, the final group tokens and private tokens will be multiplied by the above multipliers. You may hide the multiplier values from the participants.",
                            @"sectionOptions" : @[@{@"optionTitle" : @"Private Multiplier", @"optionType" : @"decimal", @"optionKey" : MULTIPLIERS_PRIVATE},
                                                  @{@"optionTitle" : @"Private Multiplier Visible", @"optionType" : @"bool", @"optionKey" : MULTIPLIERS_PRIVATE_VISIBLE},
                                                  @{@"optionTitle" : @"Group Multiplier", @"optionType" : @"decimal", @"optionKey" : MULTIPLIERS_GROUP},
                                                  @{@"optionTitle" : @"Group Multiplier Visible", @"optionType" : @"bool", @"optionKey" : MULTIPLIERS_GROUP_VISIBLE}]},
                          @{@"sectionTitle" : @"Maximums",
                            @"sectionFooter" : @"During each round, a participant can give and/or take tokens to/from the group limited by the above maximums.",
                            @"sectionOptions" : @[@{@"optionTitle" : @"Give To Group", @"optionType" : @"integer", @"optionKey" : MAXIMUM_GIVEGROUP},
                                                  @{@"optionTitle" : @"Take From Group", @"optionType" : @"integer", @"optionKey" : MAXIMUM_TAKEGROUP}]},
                          @{@"sectionTitle" : @"Token Value",
                            @"sectionFooter" : @"Set a hypothetical real-world worth of one token in cents.",
                            @"sectionOptions" : @[@{@"optionTitle" : @"Cents (per Token)", @"optionType" : @"integer", @"optionKey" : TOKEN_CENTVALUE}]},
                          @{@"sectionTitle" : @"Time",
                            @"sectionOptions" : @[@{@"optionTitle" : @"Round Seconds", @"optionType" : @"integer", @"optionKey" : TIME_ROUNDSECONDS},
                                                  @{@"optionTitle" : @"Result Seconds", @"optionType" : @"integer", @"optionKey" : TIME_RESULTSECONDS}]},
                          @{@"sectionTitle" : @"Rounds",
                            @"sectionOptions" : @[@{@"optionTitle" : @"Number of Rounds", @"optionType" : @"integer", @"optionKey" : ROUNDS}]}] mutableCopy];;
        
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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"OptionsCell" bundle:nil] forCellReuseIdentifier:@"OptionsCell"];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.tapGesture setCancelsTouchesInView:FALSE];
    [self.view addGestureRecognizer:self.tapGesture];
    
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
- (IBAction)next:(id)sender {
    if ([self validateConfig]) {
        [self performSegueWithIdentifier:@"toParticipantsConnection" sender:sender];
    }
}

//------------------------------------------------------------------------------
- (void)handleSingleTap:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

//------------------------------------------------------------------------------
- (void)showInvalidOptionAlert:(NSString*)message {
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Option Invalid"
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
    [alert show];
}

//------------------------------------------------------------------------------
- (void)showInvalidConfigAlert:(NSString*)message {
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Configuration Invalid"
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
    [alert show];
}

//------------------------------------------------------------------------------
- (void)updateBOOLOption:(BOOL)value atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* option = self.optionsList[indexPath.section][@"sectionOptions"][indexPath.row];
    
    [Options setBOOL:option[@"optionKey"] withValue:value];
    
    [self.tableView reloadData];
}

//------------------------------------------------------------------------------
- (void)updateTextOption:(NSString*)value atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* option = self.optionsList[indexPath.section][@"sectionOptions"][indexPath.row];
    
    if ([option[@"optionType"] isEqualToString:@"string"]) {
        if (value.length == 0) {
            [self showInvalidOptionAlert:@"Option value cannot be blank."];
            [self.indexesInError addObject:indexPath];
        } else if (value.length > 30) {
            [self showInvalidOptionAlert:@"Option value exceeds maximum length."];
            [self.indexesInError addObject:indexPath];
        } else {
            [Options setString:option[@"optionKey"] withValue:value];
            [self.indexesInError removeObject:indexPath];
        }
        
    } else if ([option[@"optionType"] isEqualToString:@"integer"]) {
        NSInteger integerValue = [value integerValue];
        
        if (value.length == 0) {
            [self showInvalidOptionAlert:@"Option value cannot be blank."];
            [self.indexesInError addObject:indexPath];
        } else if (integerValue == 0 && ![value isEqualToString:@"0"]) {
            [self showInvalidOptionAlert:@"Option value is not a valid number."];
            [self.indexesInError addObject:indexPath];
        } else if (integerValue > 1000) {
            [self showInvalidOptionAlert:@"Option value exceeds maximum of 1000."];
            [self.indexesInError addObject:indexPath];
        } else if (integerValue < 0) {
            [self showInvalidOptionAlert:@"Option value cannot be negative."];
            [self.indexesInError addObject:indexPath];
        } else {
            [Options setNumber:option[@"optionKey"] withValue:[NSNumber numberWithInteger:integerValue]];
            [self.indexesInError removeObject:indexPath];
        }
        
    } else if ([option[@"optionType"] isEqualToString:@"decimal"]) {
        float floatValue = [value floatValue];
        
        if (value.length == 0) {
            [self showInvalidOptionAlert:@"Option value cannot be blank."];
            [self.indexesInError addObject:indexPath];
        } else if  (floatValue <= 0) {
            [self showInvalidOptionAlert:@"Option value must be greater than 0."];
            [self.indexesInError addObject:indexPath];
        } else if (floatValue > 100) {
            [self showInvalidOptionAlert:@"Option value exceeds maximum of 100."];
            [self.indexesInError addObject:indexPath];
        } else {
            [Options setNumber:option[@"optionKey"] withValue:[NSNumber numberWithFloat:floatValue]];
            [self.indexesInError removeObject:indexPath];
            
        }
        
    }
    
    if ([self.indexesInError count]) {
        [self.nextButton setEnabled:FALSE];
    } else {
        [self.nextButton setEnabled:TRUE];
    }
    
    [self.tableView reloadData];
}

//------------------------------------------------------------------------------
- (BOOL)validateConfig {
    if ([[Options getNumber:TOKEN_PRIVATE_INITIAL] integerValue] + [[Options getNumber:TOKEN_GROUP_INITIAL] integerValue] == 0) {
        [self showInvalidConfigAlert:@"Your configuration does not have any initial tokens. Initial Private Tokens and Group Tokens cannot both be 0."];
        return FALSE;
    }
    
    if ([[Options getNumber:MAXIMUM_TAKEGROUP] integerValue] + [[Options getNumber:MAXIMUM_GIVEGROUP] integerValue] == 0) {
        [self showInvalidConfigAlert:@"Your configuration's maximums do not allow any transfer of tokens. Give To Group and Take From Group cannot both be 0."];
        return FALSE;
    }
    
    if ([[Options getNumber:TIME_RESULTSECONDS] integerValue] == 0 || [[Options getNumber:TIME_ROUNDSECONDS] integerValue] == 0) {
        [self showInvalidConfigAlert:@"Your configuration has invalid times. Round Seconds and Result Seconds must be greater than 0."];
        return FALSE;
    }
    
    if ([[Options getNumber:ROUNDS] integerValue] == 0) {
        [self showInvalidConfigAlert:@"Your configuration has an invalid Round count. Round must be greater than 0."];
        return FALSE;
    }
    
    if ([[Options getNumber:TOKEN_PRIVATE_INITIAL] integerValue] < [[Options getNumber:MAXIMUM_GIVEGROUP] integerValue]) {
        [self showInvalidConfigAlert:
         [NSString stringWithFormat:@"Your configuration sets a Give To Group maximum of %d that exceeds the available initial Private Token amount of %d.",
          [[Options getNumber:MAXIMUM_GIVEGROUP] integerValue],
          [[Options getNumber:TOKEN_PRIVATE_INITIAL] integerValue]]];
        return FALSE;
    }
    
    if ([[Options getNumber:TOKEN_GROUP_INITIAL] integerValue] < ([[Options getNumber:MAXIMUM_TAKEGROUP] integerValue] * [[Options getParticipants] count])) {
        [self showInvalidConfigAlert:
         [NSString stringWithFormat:@"Your configuration sets a Take From Group maximum of %d allowing %d participant(s) to take %d tokens that exceeds the available initial Group Token amount of %d.",
          [[Options getNumber:MAXIMUM_TAKEGROUP] integerValue],
          [[Options getParticipants] count],
          ([[Options getNumber:MAXIMUM_TAKEGROUP] integerValue] * [[Options getParticipants] count]),
          [[Options getNumber:TOKEN_GROUP_INITIAL] integerValue]]];
        return FALSE;
    }
    
    return TRUE;
}

//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OptionsCell* cell = (OptionsCell*)[tableView dequeueReusableCellWithIdentifier:@"OptionsCell"];
    [cell setOptionsViewController:self];
    [cell setIndexPath:indexPath];
    
    NSDictionary* option = self.optionsList[indexPath.section][@"sectionOptions"][indexPath.row];
    
    [cell.optionLabel setText:option[@"optionTitle"]];
    
    if ([option[@"optionType"] isEqualToString:@"bool"]) {
        [cell.optionBoolValue setHidden:FALSE];
        [cell.optionTextValue setHidden:TRUE];
        
        [cell.optionBoolValue setOn:[Options getBOOL:option[@"optionKey"]]];
    } else {
        [cell.optionBoolValue setHidden:TRUE];
        [cell.optionTextValue setHidden:FALSE];
        
        if ([option[@"optionType"] isEqualToString:@"string"]) {
            [cell.optionTextValue setKeyboardType:UIKeyboardTypeDefault];
            [cell.optionTextValue setText:[Options getString:option[@"optionKey"]]];
        } else if ([option[@"optionType"] isEqualToString:@"integer"]) {
            [cell.optionTextValue setKeyboardType:UIKeyboardTypeNumberPad];
            [cell.optionTextValue setText:[[Options getNumber:option[@"optionKey"]] stringValue]];
        } else if ([option[@"optionType"] isEqualToString:@"decimal"]) {
            [cell.optionTextValue setKeyboardType:UIKeyboardTypeDecimalPad];
            [cell.optionTextValue setText:[[Options getNumber:option[@"optionKey"]] stringValue]];
        }
        
        if ([self.indexesInError containsObject:indexPath]) {
            [cell.optionTextValue setText:@""];
        }
    }
    
    if ([self.indexesInError containsObject:indexPath]) {
        [cell setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.25]];
    } else {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    
    return cell;
}

//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return [self.optionsList[section][@"sectionOptions"] count];
}

//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return [self.optionsList count];
}

//------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.optionsList[section][@"sectionTitle"];
}

//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.optionsList[section][@"sectionFooter"]) {
        return 100.0f;
    }
    
    return  0.0f;
}

//------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.optionsList[section][@"sectionFooter"] == nil) {
        return nil;
    }
    
    UIView* footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 100.0)];
    footer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    footer.backgroundColor = [UIColor clearColor];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300.0, 85.0)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.optionsList[section][@"sectionFooter"];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor grayColor];
    
    [footer addSubview:label];
    
    return footer;
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
