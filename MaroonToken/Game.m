//
//  Game.m
//  MaroonToken
//

#import "Game.h"
#import "Packet.h"
#import "PacketStartRound.h"
#import "PacketClientEndRound.h"
#import "PacketStartResults.h"
#import "PacketServerReady.h"
#import "PacketSignInResponse.h"
#import "PacketOtherClientQuit.h"
#import "Round.h"
#import "Player.h"
#import "Options.h"

@interface Game ()

@property (nonatomic, strong) NSMutableArray* groupGroupTokens;

@property (nonatomic, strong) GKSession* session;
@property (nonatomic, strong) NSString* serverPeerID;
@property (nonatomic, strong) NSString* localPlayerName;
@property (nonatomic, assign) int sendPacketNumber;

@property (nonatomic, strong) NSTimer* sociTimer;
@property (nonatomic, assign) int countdown;

@end


@implementation Game

static Game* instance = nil;

//------------------------------------------------------------------------------
- (id)init {
	if ((self = [super init])) {
		_players = [NSMutableDictionary dictionaryWithCapacity:10];
		_roundNum = 0;
        _groupGroupTokens = [[NSMutableArray alloc] init];
	}
	return self;
}

//------------------------------------------------------------------------------
+ (Game*)sharedInstance {
    Game* result = nil;
    
    @synchronized(self) {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
        result = instance;
    }
    return result;
}

//------------------------------------------------------------------------------
- (BOOL)hasSession {
    return (self.session != nil);
}

//------------------------------------------------------------------------------
// Timer
//------------------------------------------------------------------------------
- (void)startTimer:(int)seconds {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopTimer];
        
        self.countdown = seconds;
        self.sociTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(timerTicked)
                                                        userInfo:nil
                                                         repeats:TRUE];
    });
}

//------------------------------------------------------------------------------
- (void)stopTimer {
    if (self.sociTimer != nil) {
        [self.sociTimer invalidate];
        self.sociTimer = nil;
    }
}

//------------------------------------------------------------------------------
- (void)timerTicked {
    self.countdown -= 1;

    if (self.countdown <= 0) {
        [self stopTimer];
        if ([self receivedEndRoundFromAllPlayers])
        {
            [self startTimer:self.round.resultTime];
            self.state = GameStateInResults;
            [self startResultsServer];
        }
        if ([self receivedEndResultsFromAllPlayers])
        {
            self.state = GameStateWaitingForReady;
            [self startRoundServer];
        }
    }
}


//------------------------------------------------------------------------------
- (void)quitGameWithReason:(QuitReason)reason {
    if (self.state != GameStateQuitting) {
        self.state = GameStateQuitting;
        
        if (reason == QuitReasonUserQuit) {
            if (self.isServer) {
                Packet* packet = [Packet packetWithType:PacketTypeServerQuit];
                [self sendPacketToAllClients:packet];
            } else {
                Packet* packet = [Packet packetWithType:PacketTypeClientQuit];
                [self sendPacketToServer:packet];
            }
        }
        
        [self.session disconnectFromAllPeers];
        self.session.delegate = nil;
        self.session = nil;
        
        [self.delegate game:self didQuitWithReason:reason];
    }
}

//------------------------------------------------------------------------------
- (Player*)playerWithPeerID:(NSString*)peerID {
	return [self.players objectForKey:peerID];
}

//------------------------------------------------------------------------------
// Game Logic - Server
//------------------------------------------------------------------------------
- (void)startServerGameWithSession:(GKSession*)session playerName:(NSString*)name clients:(NSArray*)clients {
    // Reset properties
    self.players = [NSMutableDictionary dictionaryWithCapacity:10];
    self.roundNum = 0;
    self.groupGroupTokens = [[NSMutableArray alloc] init];
    self.isFinished = FALSE;
    
    // Set Round
    self.round = [[Round alloc] init];
    self.round.experimentName = [Options getString:EXPERIMENT_ID];
    self.round.surveyURL      = @"";
    
    self.round.groupVisible            = [Options getBOOL:TOKEN_GROUP_VISIBLE];
    self.round.privateVisible          = [Options getBOOL:TOKEN_PRIVATE_VISIBLE];
    self.round.groupMultiplierVisible  = [Options getBOOL:MULTIPLIERS_GROUP_VISIBLE];
    self.round.privateMultiplieVisible = [Options getBOOL:MULTIPLIERS_PRIVATE_VISIBLE];
    
    self.round.groupTokens       = [[Options getNumber:TOKEN_GROUP_INITIAL] intValue];
    self.round.privateTokens     = [[Options getNumber:TOKEN_PRIVATE_INITIAL] intValue];
    
    self.round.groupMultiplier   = [[Options getNumber:MULTIPLIERS_GROUP] floatValue];
    self.round.privateMultiplier = [[Options getNumber:MULTIPLIERS_PRIVATE] floatValue];
    self.round.tokenToCents      = [[Options getNumber:TOKEN_CENTVALUE] floatValue];
    
    self.round.maxGive = [[Options getNumber:MAXIMUM_GIVEGROUP] intValue];
    self.round.maxTake = [[Options getNumber:MAXIMUM_TAKEGROUP] intValue];
    
    self.round.roundTime  = [[Options getNumber:TIME_ROUNDSECONDS] intValue];
    self.round.resultTime = [[Options getNumber:TIME_RESULTSECONDS] intValue];
    
    self.round.numOfRounds = [[Options getNumber:ROUNDS] intValue];
    
	self.isServer = YES;
    
	self.session = session;
	self.session.available = NO;
	self.session.delegate = self;
	[self.session setDataReceiveHandler:self withContext:nil];
    
	self.state = GameStateWaitingForSignIn;
    
	[self.delegate gameWaitingForClientsReady:self];
    
	// Create the Player object for the server.
	Player* player = [[Player alloc] init];
	player.name = @"Server";
	player.peerID = self.session.peerID;
	player.position = PlayerPositionNone;
    player.groupID = -1;
    player.groupSize = -1;
	[self.players setObject:player forKey:player.peerID];
    
	// Add a Player object for each client.
	for (NSString* peerID in clients) {
		Player* player = [[Player alloc] init];
		player.peerID = peerID;
        player.name = [self.session displayNameForPeer:peerID];
		[self.players setObject:player forKey:player.peerID];
        
        // Not used:
        player.position = PlayerPositionNone;
        player.groupID = 0;
        
        player.groupSize = [clients count];
	}
    
	Packet* packet = [Packet packetWithType:PacketTypeSignInRequest];
	[self sendPacketToAllClients:packet];
}

//------------------------------------------------------------------------------
- (void)startRoundServer {
    self.roundNum += 1;
    
    [self.delegate startViewingRound:self];
    
    self.state = GameStateInRound;
    
    Player* player = [self playerWithPeerID:self.session.peerID];
    player.finishedResults = TRUE;
    player.finishedRound = TRUE;
    
    Packet* packet = [PacketStartRound packetWithRound:self.round];
    [self sendPacketToAllClients:packet];
    
    [self startTimer:self.round.roundTime];
    
    [self.groupGroupTokens removeAllObjects];
    [self.groupGroupTokens addObject:[NSNumber numberWithInteger:self.round.groupTokens]];
}

//------------------------------------------------------------------------------
- (void)startResultsServer {
    if (self.roundNum >= self.round.numOfRounds) {
        self.isFinished = TRUE;
    }
    
    [self.delegate startViewingResults:self myPlayer:[self playerWithPeerID:self.session.peerID]];
    
    Packet* packet = [PacketStartResults packetWithTokens:self.groupGroupTokens];
    [self sendPacketToAllClients:packet];
}


//------------------------------------------------------------------------------
// Game Logic - Client
//------------------------------------------------------------------------------
- (void)startClientGameWithSession:(GKSession*)session playerName:(NSString*)name server:(NSString*)peerID {
    // Reset properties
    self.players = [NSMutableDictionary dictionaryWithCapacity:10];
    self.roundNum = 0;
    self.groupGroupTokens = [[NSMutableArray alloc] init];
    self.isFinished = FALSE;
    
	self.isServer = NO;
    
	self.session = session;
	self.session.available = NO;
	self.session.delegate = self;
	[self.session setDataReceiveHandler:self withContext:nil];
    
	self.serverPeerID = peerID;
	self.localPlayerName = name;
    
	self.state = GameStateWaitingForSignIn;
    
	[self.delegate gameWaitingForServerReady:self];
}

//------------------------------------------------------------------------------
- (void)startRoundClient {
    self.state = GameStateInRound;
    [self.delegate startViewingRound:self];
    
}

//------------------------------------------------------------------------------
- (void)stopRoundClient {
    [self.delegate stopViewingRound:self];
}

//------------------------------------------------------------------------------
- (void)endRoundClientWithTakeGive:(NSInteger)takes gives:(NSInteger)gives {
    Player* myPlayer = [self playerWithPeerID:self.session.peerID];
    [myPlayer.roundGiveTokens addObject:[NSNumber numberWithInteger:gives]];
    [myPlayer.roundTakeTokens addObject:[NSNumber numberWithInteger:takes]];
    
    Packet* packet = [PacketClientEndRound packetWithTokens:takes roundGiveTokens:gives];
    [self sendPacketToServer:packet];
}

//------------------------------------------------------------------------------
- (void)startResultsClient {
    if ((self.roundNum+1) >= self.round.numOfRounds) {
        self.isFinished = TRUE;
    }
    
    self.state = GameStateInResults;
    [self.delegate startViewingResults:self myPlayer:[self playerWithPeerID:self.session.peerID]];
}

//------------------------------------------------------------------------------
- (void)stopResultsClient {
    [self.delegate stopViewingResults:self];
}

//------------------------------------------------------------------------------
- (void)endResultsClient {
    // Next Round
    self.roundNum += 1;
    Packet* packet = [Packet packetWithType:PacketTypeClientEndResults];
    [self sendPacketToServer:packet];
}


//------------------------------------------------------------------------------
// Networking - Server
//------------------------------------------------------------------------------
- (void)sendPacketToAllClients:(Packet*)packet {
	// If packet numbering is enabled, each packet that we send out gets a
	// unique number that keeps increasing. This is used to ignore packets
	// that arrive out-of-order.
	if (packet.packetNumber != -1)
		packet.packetNumber = self.sendPacketNumber++;
    
	[self.players enumerateKeysAndObjectsUsingBlock:^(id key, Player* obj, BOOL* stop) {
         obj.receivedResponse = [self.session.peerID isEqualToString:obj.peerID];
     }];
    
	GKSendDataMode dataMode = packet.sendReliably ? GKSendDataReliable : GKSendDataUnreliable;
    
	NSData* data = [packet data];
	NSError* error;
	if (![self.session sendDataToAllPeers:data withDataMode:dataMode error:&error]) {
		NSLog(@"Error sending data to clients: %@", error);
	}
}

//------------------------------------------------------------------------------
- (BOOL)receivedEndRoundFromAllPlayers {
	for (NSString* peerID in self.players) {
		Player* player = [self playerWithPeerID:peerID];
		if (!player.finishedRound)
			return NO;
	}
    
    // Reset
    for (NSString* peerID in self.players) {
		Player* player = [self playerWithPeerID:peerID];
		player.finishedRound = NO;
	}
	return YES;
}

//------------------------------------------------------------------------------
- (BOOL)receivedEndResultsFromAllPlayers {
	for (NSString* peerID in self.players) {
		Player* player = [self playerWithPeerID:peerID];
		if (!player.finishedResults)
			return NO;
	}
    
    // Reset
    for (NSString* peerID in self.players) {
		Player* player = [self playerWithPeerID:peerID];
		player.finishedResults = NO;
	}
	return YES;
}

//------------------------------------------------------------------------------
- (BOOL)receivedResponsesFromAllPlayers {
	for (NSString* peerID in self.players) {
		Player* player = [self playerWithPeerID:peerID];
		if (!player.receivedResponse) {
			return NO;
        }
	}
    
	return YES;
}


//------------------------------------------------------------------------------
// Networking - Client
//------------------------------------------------------------------------------
- (void)sendPacketToServer:(Packet*)packet {
	if (packet.packetNumber != -1) {
		packet.packetNumber = self.sendPacketNumber++;
    }
    
	GKSendDataMode dataMode = packet.sendReliably ? GKSendDataReliable : GKSendDataUnreliable;
    
	NSData* data = [packet data];
	NSError* error;
	if (![self.session sendData:data toPeers:[NSArray arrayWithObject:self.serverPeerID] withDataMode:dataMode error:&error]) {
		NSLog(@"Error sending data to server: %@", error);
	}
}


//------------------------------------------------------------------------------
// GKSessionDelegate
//------------------------------------------------------------------------------
- (void)session:(GKSession*)session peer:(NSString*)peerID didChangeState:(GKPeerConnectionState)state {
	if (state == GKPeerStateDisconnected) {
		if (self.isServer) {
		
        } else if ([peerID isEqualToString:self.serverPeerID]) {
			[self quitGameWithReason:QuitReasonConnectionDropped];
		}
	}
}

//------------------------------------------------------------------------------
- (void)session:(GKSession*)session didReceiveConnectionRequestFromPeer:(NSString*)peerID {
	[session denyConnectionFromPeer:peerID];
}

//------------------------------------------------------------------------------
- (void)session:(GKSession*)session connectionWithPeerFailed:(NSString*)peerID withError:(NSError*)error {
	// Not used.
}

//------------------------------------------------------------------------------
- (void)session:(GKSession*)session didFailWithError:(NSError*)error {
	if ([[error domain] isEqualToString:GKSessionErrorDomain]) {
		if (self.state != GameStateQuitting) {
			[self quitGameWithReason:QuitReasonConnectionDropped];
		}
	}
}


//------------------------------------------------------------------------------
// GKSession - Packet Handler
//------------------------------------------------------------------------------
- (void)receiveData:(NSData*)data fromPeer:(NSString*)peerID inSession:(GKSession*)session context:(void*)context {
	Packet* packet = [Packet packetWithData:data];
	if (packet == nil) {
		NSLog(@"Invalid packet: %@", data);
		return;
	}
    
	Player* player = [self playerWithPeerID:peerID];
	if (player != nil) {
		if (packet.packetNumber != -1 && packet.packetNumber <= player.lastPacketNumberReceived) {
			NSLog(@"Out-of-order packet!");
			return;
		}
        
		player.lastPacketNumberReceived = packet.packetNumber;
		player.receivedResponse = YES;
	}
    
	if (self.isServer) {
		[self serverReceivedPacket:packet fromPlayer:player];
	} else {
		[self clientReceivedPacket:packet];
    }
}


//------------------------------------------------------------------------------
// GKSession - Packet Handler - Server
//------------------------------------------------------------------------------
- (void)serverReceivedPacket:(Packet*)packet fromPlayer:(Player*)player {
	switch (packet.packetType) {
		case PacketTypeSignInResponse:
			if (self.state == GameStateWaitingForSignIn) {
				player.name = ((PacketSignInResponse*)packet).playerName;
                
				if ([self receivedResponsesFromAllPlayers]) {
					self.state = GameStateWaitingForReady;
                    
					Packet* packet = [PacketServerReady packetWithPlayers:self.players];
					[self sendPacketToAllClients:packet];
				}
			}
			break;
            
		case PacketTypeClientReady:
			if (self.state == GameStateWaitingForReady && [self receivedResponsesFromAllPlayers]) {
				[self startRoundServer];
			}
			break;
            
        case PacketTypeClientEndRound:
            if (self.state == GameStateInRound) {
                [self handlePacketClientEndRound:(PacketClientEndRound*)packet player:player];
                player.finishedRound = TRUE;
                
				if (self.countdown <= 0 && [self receivedEndRoundFromAllPlayers]) {
                    [self startTimer:self.round.resultTime];
                    self.state = GameStateInResults;
                    [self startResultsServer];
				}
			}
            
			break;
            
        case PacketTypeClientEndResults:
            if (self.state == GameStateInResults) {
                player.finishedResults = TRUE;
                if (self.countdown <= 0 && [self receivedEndResultsFromAllPlayers]) {
                    self.state = GameStateWaitingForReady;
					[self startRoundServer];
				}
            }
            
			break;
            
		case PacketTypeClientQuit:
            [self quitGameWithReason:QuitReasonUserQuit];
			break;
            
		default:
			NSLog(@"Server received unexpected packet: %@", packet);
			break;
	}
}

//------------------------------------------------------------------------------
- (void)handlePacketClientEndRound:(PacketClientEndRound*)packet player:(Player*)player {
    [player.roundGiveTokens addObject:[NSNumber numberWithInteger:packet.roundGiveTokens]];
    [player.roundTakeTokens addObject:[NSNumber numberWithInteger:packet.roundTakeTokens]];
    
    int previousGroupTokens = [[self.groupGroupTokens objectAtIndex:player.groupID] intValue];
    int currentGroupTokens = previousGroupTokens + packet.roundGiveTokens - packet.roundTakeTokens;
    
    [self.groupGroupTokens replaceObjectAtIndex:player.groupID withObject:[NSNumber numberWithInteger:currentGroupTokens]];
}


//------------------------------------------------------------------------------
// GKSession - Packet Handler - Client
//------------------------------------------------------------------------------
- (void)clientReceivedPacket:(Packet*)packet {
	switch (packet.packetType) {
		case PacketTypeSignInRequest:
			if (self.state == GameStateWaitingForSignIn)
			{
				self.state = GameStateWaitingForReady;
                
				Packet* packet = [PacketSignInResponse packetWithPlayerName:self.localPlayerName];
				[self sendPacketToServer:packet];
			}
			break;
            
		case PacketTypeServerReady:
			if (self.state == GameStateWaitingForReady)
			{
				self.players = ((PacketServerReady*)packet).players;
				Packet* packet = [Packet packetWithType:PacketTypeClientReady];
				[self sendPacketToServer:packet];
			}
			break;
            
        case PacketTypeStartRound:
			self.round = ((PacketStartRound*)packet).round;
            [self startRoundClient];
			break;
            
        case PacketTypeStartResults:
        {
            [self handlePacketStartResults:(PacketStartResults*)packet];
            [self startResultsClient];
        }
			break;
            
		case PacketTypeOtherClientQuit:
			[self quitGameWithReason:QuitReasonUserQuit];
			break;
            
		case PacketTypeServerQuit:
			[self quitGameWithReason:QuitReasonServerQuit];
			break;
            
		default:
			NSLog(@"Client received unexpected packet: %@", packet);
			break;
	}
}

//------------------------------------------------------------------------------
- (void)handlePacketStartResults:(PacketStartResults*)packet {
    Player* myPlayer = [self playerWithPeerID:self.session.peerID];

    int privateTokens = self.round.privateTokens - [[myPlayer.roundGiveTokens objectAtIndex:self.roundNum] intValue] + [[myPlayer.roundTakeTokens objectAtIndex:self.roundNum] intValue];
    
    int groupTokens = [[packet.roundGroupTokens objectAtIndex:myPlayer.groupID] intValue];

    [myPlayer.roundPrivateTokens addObject:[NSNumber numberWithInteger:privateTokens]];
    [myPlayer.roundGroupTokens addObject:[NSNumber numberWithInteger:groupTokens]];
}

@end
