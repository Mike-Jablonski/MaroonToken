//
//  MatchmakingServer.m
//  MaroonToken
//

#import "MatchmakingServer.h"

typedef enum {
	ServerStateIdle,
	ServerStateAcceptingConnections,
	ServerStateIgnoringNewConnections,
}
ServerState;


@interface MatchmakingServer ()

@property (nonatomic, assign) ServerState serverState;

@end


@implementation MatchmakingServer

//------------------------------------------------------------------------------
- (id)init {
	if ((self = [super init])) {
		_serverState = ServerStateIdle;
        _displayName = nil;
	}
	
    return self;
}

//------------------------------------------------------------------------------
- (void)startAcceptingConnectionsForSessionID:(NSString*)sessionID {
    if (self.serverState == ServerStateIdle) {
		self.serverState = ServerStateAcceptingConnections;
        self.connectedClients = [NSMutableArray arrayWithCapacity:self.maxClients];
        
        self.session = [[GKSession alloc] initWithSessionID:sessionID displayName:self.displayName sessionMode:GKSessionModeServer];
        self.session.delegate = self;
        self.session.available = YES;
    }
}

//------------------------------------------------------------------------------
// GKSessionDelegate
//------------------------------------------------------------------------------
- (void)session:(GKSession*)session peer:(NSString*)peerID didChangeState:(GKPeerConnectionState)state {
	switch (state) {
		case GKPeerStateAvailable:
			break;
            
		case GKPeerStateUnavailable:
			break;
            
        // A new client has connected to the server.
		case GKPeerStateConnected:
			if (self.serverState == ServerStateAcceptingConnections) {
				if (![self.connectedClients containsObject:peerID]) {
					[self.connectedClients addObject:peerID];
					[self.delegate matchmakingServer:self clientDidConnect:peerID];
				}
			}
			break;
            
        // A client has disconnected from the server.
		case GKPeerStateDisconnected:
			if (self.serverState != ServerStateIdle) {
				if ([self.connectedClients containsObject:peerID]) {
					[self.connectedClients removeObject:peerID];
					[self.delegate matchmakingServer:self clientDidDisconnect:peerID];
				}
			}
			break;
            
		case GKPeerStateConnecting:
			break;
	}
}

//------------------------------------------------------------------------------
- (void)session:(GKSession*)session didReceiveConnectionRequestFromPeer:(NSString*)peerID {
    BOOL listedPlayer = FALSE;
    BOOL notconnected = TRUE;
    
    for (NSString* listedPlayerName in self.playerList) {
        if ([listedPlayerName caseInsensitiveCompare:[session displayNameForPeer:peerID]] == NSOrderedSame) {
            listedPlayer = TRUE;
        }
    }
    
    if (!listedPlayer) {
        [self.delegate matchmakingServer:self clientNotListed:[session displayNameForPeer:peerID]];
    }
    
    for (int i = 0; i<[self connectedClientCount]; i++) {
        if ([[self displayNameForPeerID:[self peerIDForConnectedClientAtIndex:i]]caseInsensitiveCompare:[session displayNameForPeer:peerID]] == NSOrderedSame) {
            notconnected = FALSE;
            [self.delegate matchmakingServer:self clientDuplicate:[session displayNameForPeer:peerID]];
        }
    }
    
	if (self.serverState == ServerStateAcceptingConnections && [self connectedClientCount] < self.maxClients && listedPlayer && notconnected) {
		NSError* error;
		[session acceptConnectionFromPeer:peerID error:&error];
	} else {
		[session denyConnectionFromPeer:peerID];
	}
}

//------------------------------------------------------------------------------
- (void)session:(GKSession*)session connectionWithPeerFailed:(NSString*)peerID withError:(NSError*)error {
    
}

//------------------------------------------------------------------------------
- (void)session:(GKSession*)session didFailWithError:(NSError*)error {
	if ([[error domain] isEqualToString:GKSessionErrorDomain]) {
		if ([error code] == GKSessionCannotEnableError) {
			[self.delegate matchmakingServerNoNetwork:self];
			[self endSession];
		}
	}
}

//------------------------------------------------------------------------------
- (NSUInteger)connectedClientCount {
	return [self.connectedClients count];
}

//------------------------------------------------------------------------------
- (NSString*)peerIDForConnectedClientAtIndex:(NSUInteger)index {
	return [self.connectedClients objectAtIndex:index];
}

//------------------------------------------------------------------------------
- (NSString*)displayNameForPeerID:(NSString*)peerID {
	return [self.session displayNameForPeer:peerID];
}

//------------------------------------------------------------------------------
- (void)stopAcceptingConnections {
	self.serverState = ServerStateIgnoringNewConnections;
	self.session.available = NO;
}

//------------------------------------------------------------------------------
- (void)endSession {
	self.serverState = ServerStateIdle;
    
	[self.session disconnectFromAllPeers];
	self.session.available = NO;
	self.session.delegate = nil;
	self.session = nil;
    
	self.connectedClients = nil;
    
	[self.delegate matchmakingServerSessionDidEnd:self];
}

@end
