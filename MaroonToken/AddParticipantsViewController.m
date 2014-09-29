//
//  AddParticipantsViewController.m
//  MaroonToken
//
//  Created by Mike Jablonski on 8/11/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "AddParticipantsViewController.h"
#import "ParticipantCell.h"
#import "Options.h"

@interface AddParticipantsViewController ()

@property (nonatomic, strong) NSMutableArray* participantList;
@property (nonatomic, strong) NSMutableSet* indexesInError;
@property (nonatomic, assign) BOOL isKeyboardObserver;
@property (nonatomic, assign) BOOL isVisible;

@end


@implementation AddParticipantsViewController

//------------------------------------------------------------------------------
// View
//------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _participantList = [[NSMutableArray alloc] init];
        _indexesInError = [[NSMutableSet alloc] init];
        _isKeyboardObserver = FALSE;
        _isVisible = FALSE;
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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ParticipantCell" bundle:nil] forCellReuseIdentifier:@"ParticipantCell"];
    self.tableView.allowsMultipleSelectionDuringEditing = FALSE;
    
    [self.nextButton setEnabled:FALSE];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.isKeyboardObserver = TRUE;
}

//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setIsVisible:TRUE];
}

//------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self setIsVisible:FALSE];
}

//------------------------------------------------------------------------------
- (void)showInvalidAlert {
    UIAlertView* alert = [[UIAlertView alloc ] initWithTitle:@"Participant(s) Invalid"
                                                     message:@"Participants must have non-blank, unique IDs."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
    [alert show];
}

//------------------------------------------------------------------------------
// Actions
//------------------------------------------------------------------------------
- (IBAction)next:(id)sender {
    if ([self validateParticipants]) {
        [Options setParticipants:[self.participantList valueForKey:@"name"]];
        [self performSegueWithIdentifier:@"participantsToOptions" sender:sender];
    }
}

//------------------------------------------------------------------------------
- (IBAction)addParticipant:(id)sender {
    [self.participantList addObject:@{@"error" : @0, @"new" : @1, @"name" : @""}];
    
    if ([self.participantList count] >= 5) {
        [self.addButton setEnabled:FALSE];
    } else {
        [self.addButton setEnabled:TRUE];
    }
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([self.participantList count] -1) inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

//------------------------------------------------------------------------------
- (void)updateParticipant:(NSString*)name atIndexPath:(NSIndexPath *)indexPath {
    if (!self.isVisible) {
        // Avoid alerting the user when navigated off this view
        return;
    }
    
    NSMutableDictionary* participant = [[self.participantList objectAtIndex:indexPath.row] mutableCopy];
    participant[@"name"] = name;
    
    [self.participantList replaceObjectAtIndex:indexPath.row withObject:participant];
    
    [self validateParticipants];
    
    [self.tableView reloadData];
}

//------------------------------------------------------------------------------
- (BOOL)validateParticipants {
    NSCountedSet* countedSet = [[NSCountedSet alloc] initWithArray:[self.participantList valueForKey:@"name"]];
    
    NSMutableSet* invalidNames = [@[@""] mutableCopy];
    
    for (NSString* name in countedSet) {
        if ([countedSet countForObject:name] > 1)
            [invalidNames addObject:name];
    }
    
    BOOL hasInvalidParticipants = FALSE;
    NSMutableArray* updatedParticipantList = [[NSMutableArray alloc] init];
    
    for (NSDictionary* participant in self.participantList) {
        if ([invalidNames containsObject:participant[@"name"]]) {
            [updatedParticipantList addObject:@{@"error" : @1, @"new" : @0, @"name" : participant[@"name"]}];
            hasInvalidParticipants = TRUE;
        } else {
            [updatedParticipantList addObject:@{@"error" : @0, @"new" : @0, @"name" : participant[@"name"]}];
        }
    }
    
    self.participantList = updatedParticipantList;
    
    if (hasInvalidParticipants) {
        [self showInvalidAlert];
    }
    
    if ([self.participantList count] == 0 || hasInvalidParticipants) {
        [self.nextButton setEnabled:FALSE];
        return FALSE;
    } else {
        [self.nextButton setEnabled:TRUE];
        return TRUE;
    }
}

//------------------------------------------------------------------------------
// TableView
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParticipantCell* cell = (ParticipantCell*)[tableView dequeueReusableCellWithIdentifier:@"ParticipantCell"];
    [cell setParticipantViewController:self];
    [cell setIndexPath:indexPath];
    
    NSDictionary* participant = [self.participantList objectAtIndex:indexPath.row];
    
    if ([participant[@"new"] boolValue]) {
        [cell.participantLabel setText:@"New Participant"];
        [cell.participantLabel setHidden:TRUE];
        
        [cell.participantTextField setText:@""];
        [cell.participantTextField setPlaceholder:@"New Participant"];
        [cell.participantTextField setHidden:FALSE];
        
        [cell.participantTextField becomeFirstResponder];
        
    } else {
        [cell.participantLabel setText:participant[@"name"]];
        [cell.participantLabel setHidden:FALSE];
        
        [cell.participantTextField setText:participant[@"name"]];
        [cell.participantTextField setPlaceholder:participant[@"name"]];
        [cell.participantTextField setHidden:TRUE];
    }
    
    if ([participant[@"error"] boolValue]) {
        [cell setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.25]];
    } else {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    
    return cell;
}

//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ParticipantCell* cell = (ParticipantCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    [cell.participantLabel setHidden:TRUE];
    [cell.participantTextField setHidden:FALSE];
    
    [cell.participantTextField becomeFirstResponder];
}

//------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
    return YES;
}

//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.participantList removeObjectAtIndex:indexPath.row];
        
        [self validateParticipants];
        
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        
        if ([self.participantList count] >= 5) {
            [self.addButton setEnabled:FALSE];
        } else {
            [self.addButton setEnabled:TRUE];
        }
    }
}

//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return [self.participantList count];
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
