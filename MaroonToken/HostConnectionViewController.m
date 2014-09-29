//
//  HostConnectionViewController.m
//  MaroonToken
//
//  Created by Mike Jablonski on 9/2/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "HostConnectionViewController.h"
#import "PeerConnectionCell.h"
#import "Options.h"
#import "Game.h"

@interface HostConnectionViewController ()

@property (nonatomic, strong) MatchmakingClient* matchmakingClient;
@property (nonatomic, strong) NSString* peerIDConnecting;

@end


@implementation HostConnectionViewController

//------------------------------------------------------------------------------
// View
//------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {

    }
    
    return self;
}

//------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PeerConnectionCell" bundle:nil] forCellReuseIdentifier:@"PeerConnectionCell"];
}

//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:TRUE];
    [self.navigationItem setHidesBackButton:FALSE];
    
    if (self.matchmakingClient != nil) {
        self.matchmakingClient.delegate = nil;
        [self.matchmakingClient disconnectFromServer];
        self.matchmakingClient = nil;
    }
    
    self.matchmakingClient = [[MatchmakingClient alloc] init];
    self.matchmakingClient.delegate = self;
    self.matchmakingClient.displayName = [Options getParticipantID];
    [self.matchmakingClient startSearchingForServersWithSessionID:@"MaroonToken"];
    
    [self.tableView reloadData];
}

//------------------------------------------------------------------------------
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.navigationController != nil) {
        if ([self.navigationController.viewControllers containsObject:self]) {
            return;
        }
    }

    // View Controller popped
    if (self.matchmakingClient != nil) {
        self.matchmakingClient.delegate = nil;
        [self.matchmakingClient disconnectFromServer];
        self.matchmakingClient = nil;
    }
}

//------------------------------------------------------------------------------
// TableView
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PeerConnectionCell* cell = (PeerConnectionCell*)[tableView dequeueReusableCellWithIdentifier:@"PeerConnectionCell"];
    
    NSString* peerID = [self.matchmakingClient peerIDForAvailableServerAtIndex:indexPath.row];
    NSString* peerName = [self.matchmakingClient displayNameForPeerID:peerID];
    
	[cell.peerLabel setText:peerName];
    [cell.activityIndicator setHidden:TRUE];
    [cell.checkmarkLabel setHidden:TRUE];
    
    if ([self.peerIDConnecting isEqualToString:peerID]) {
        [cell.activityIndicator setHidden:FALSE];
        [cell.activityIndicator startAnimating];
    }
    
    return cell;
}

//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PeerConnectionCell* cell = (PeerConnectionCell*)[tableView dequeueReusableCellWithIdentifier:@"PeerConnectionCell"];
    [cell.activityIndicator setHidden:FALSE];
    
    NSString* peerID = [self.matchmakingClient peerIDForAvailableServerAtIndex:indexPath.row];
    self.peerIDConnecting = peerID;
    [self.matchmakingClient connectToServerWithPeerID:peerID];
    
    [self.tableView reloadData];
}

//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	if (self.matchmakingClient != nil) {
		return [self.matchmakingClient availableServerCount];
    }
    
    return 0;
}

//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}


//------------------------------------------------------------------------------
// MatchmakingClientDelegate
//------------------------------------------------------------------------------
- (void)matchmakingClient:(MatchmakingClient*)client serverBecameAvailable:(NSString *)peerID {
	[self.tableView reloadData];
}

//------------------------------------------------------------------------------
- (void)matchmakingClient:(MatchmakingClient*)client serverBecameUnavailable:(NSString *)peerID {
	[self.tableView reloadData];
}

//------------------------------------------------------------------------------
- (void)matchmakingClient:(MatchmakingClient*)client didDisconnectFromServer:(NSString *)peerID {
    self.matchmakingClient = [[MatchmakingClient alloc] init];
    self.matchmakingClient.delegate = self;
    self.matchmakingClient.displayName = [Options getParticipantID];
    [self.matchmakingClient startSearchingForServersWithSessionID:@"MaroonToken"];
    
	[self.tableView reloadData];
}

//------------------------------------------------------------------------------
- (void)matchmakingClient:(MatchmakingClient*)client didConnectToServer:(NSString *)peerID {
    [[Game sharedInstance] startClientGameWithSession:client.session playerName:client.session.displayName server:peerID];
}

//------------------------------------------------------------------------------
- (void)matchmakingClientNoNetwork:(MatchmakingClient*)client {
    UIAlertView* alert =[[UIAlertView alloc ] initWithTitle:@"No Network"
                                                    message:@"No bluetooth or WiFi network detected."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
    
    [self.tableView reloadData];
}


@end
