//
//  ParticipantsConnectionViewController.m
//  MaroonToken
//
//  Created by Mike Jablonski on 9/2/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "ParticipantsConnectionViewController.h"
#import "PeerConnectionCell.h"
#import "Options.h"
#import "Game.h"

@interface ParticipantsConnectionViewController ()

@property (nonatomic, strong) NSArray* participants;
@property (nonatomic, strong) MatchmakingServer* matchmakingServer;

@end


@implementation ParticipantsConnectionViewController

//------------------------------------------------------------------------------
// View
//------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.startButton setEnabled:FALSE];
    
    self.participants = [Options getParticipants];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PeerConnectionCell" bundle:nil] forCellReuseIdentifier:@"PeerConnectionCell"];
    
}

//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:TRUE];
    [self.navigationItem setHidesBackButton:FALSE];
    
    [self.startButton setTitle:@"Start Experiment"];
    
    if (self.matchmakingServer != nil) {
        self.matchmakingServer.delegate = nil;
        [self.matchmakingServer endSession];
        self.matchmakingServer = nil;
    }
    
    self.matchmakingServer = [[MatchmakingServer alloc] init];
    self.matchmakingServer.maxClients = 6;
    self.matchmakingServer.delegate = self;
    self.matchmakingServer.playerList = self.participants;
    [self.matchmakingServer startAcceptingConnectionsForSessionID:@"MaroonToken"];
    
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
    if (self.matchmakingServer != nil) {
        self.matchmakingServer.delegate = nil;
        [self.matchmakingServer endSession];
        self.matchmakingServer = nil;
    }
}


//------------------------------------------------------------------------------
- (IBAction)start:(id)sender {
    [self.startButton setEnabled:FALSE];
    [self.startButton setTitle:@"Starting..."];
    
    [[Game sharedInstance] startServerGameWithSession:self.matchmakingServer.session playerName:@"Server" clients:self.matchmakingServer.connectedClients];
    
    [self performSegueWithIdentifier:@"toServerOverview" sender:sender];
}


//------------------------------------------------------------------------------
// TableView
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PeerConnectionCell* cell = (PeerConnectionCell*)[tableView dequeueReusableCellWithIdentifier:@"PeerConnectionCell"];
    
    NSString* peerName = [self.participants objectAtIndex:indexPath.row];
    [cell.peerLabel setText:peerName];
    
    [cell.activityIndicator setHidden:FALSE];
    [cell.activityIndicator startAnimating];
    [cell.checkmarkLabel setHidden:TRUE];
    
    for (NSString* peerID in self.matchmakingServer.connectedClients) {
        if ([peerName caseInsensitiveCompare:[self.matchmakingServer displayNameForPeerID:peerID]] == NSOrderedSame) {
            [cell.activityIndicator setHidden:TRUE];
            [cell.checkmarkLabel setHidden:FALSE];
        }
    }

    return cell;
}

//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return [self.participants count];
}

//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}


//------------------------------------------------------------------------------
// MatchmakingServerDelegate
//------------------------------------------------------------------------------
- (void)matchmakingServer:(MatchmakingServer*)server clientDidConnect:(NSString*)peerID {
	[self.tableView reloadData];
    
    if ([self.matchmakingServer.connectedClients count] == [self.participants count]) {
        [self.startButton setEnabled:TRUE];
    }
}

//------------------------------------------------------------------------------
- (void)matchmakingServer:(MatchmakingServer*)server clientDidDisconnect:(NSString*)peerID {
	[self.tableView reloadData];
}

//------------------------------------------------------------------------------
- (void)matchmakingServer:(MatchmakingServer*)server clientDuplicate:(NSString*)peerName {
    UIAlertView* alert =[[UIAlertView alloc ] initWithTitle:@"Connection Refused"
                                                    message:[NSString stringWithFormat:@"Participant with ID '%@' is already connected.", peerName]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
    
    [self.tableView reloadData];
}

//------------------------------------------------------------------------------
- (void)matchmakingServer:(MatchmakingServer*)server clientNotListed:(NSString*)peerName {
    UIAlertView* alert =[[UIAlertView alloc ] initWithTitle:@"Connection Refused"
                                                     message:[NSString stringWithFormat:@"Participant with ID '%@' is not listed.", peerName]
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
    [alert show];
    
    [self.tableView reloadData];
}

//------------------------------------------------------------------------------
- (void)matchmakingServerSessionDidEnd:(MatchmakingServer*)server {
    self.matchmakingServer = [[MatchmakingServer alloc] init];
    self.matchmakingServer.maxClients = 6;
    self.matchmakingServer.delegate = self;
    self.matchmakingServer.playerList = self.participants;
    [self.matchmakingServer startAcceptingConnectionsForSessionID:@"MaroonToken"];
    
	[self.tableView reloadData];
}

//------------------------------------------------------------------------------
- (void)matchmakingServerNoNetwork:(MatchmakingServer*)session {
    UIAlertView* alert =[[UIAlertView alloc ] initWithTitle:@"No Network"
                                                     message:@"No bluetooth or WiFi network detected."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
    [alert show];
    
    [self.tableView reloadData];
}

@end
