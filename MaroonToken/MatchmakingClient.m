//
//  MatchmakingClient.h
//  MaroonToken
//

#import "MatchmakingClient.h"

typedef enum {
	ClientStateIdle,
	ClientStateSearchingForServers,
	ClientStateConnecting,
	ClientStateConnected,
}
ClientState;


@interface MatchmakingClient ()

@property (nonatomic, assign) ClientState clientState;
@property (nonatomic, strong) NSString* serverPeerID;

@end


@implementation MatchmakingClient

//------------------------------------------------------------------------------
- (id)init {
	if ((self = [super init])) {
		_clientState = ClientStateIdle;
	}
	return self;
}

//------------------------------------------------------------------------------
- (void)startSearchingForServersWithSessionID:(NSString*)sessionID {
	if (self.clientState == ClientStateIdle) {
		self.clientState = ClientStateSearchingForServers;
		self.availableServers = [NSMutableArray arrayWithCapacity:10];
        
        self.session = [[GKSession alloc] initWithSessionID:sessionID displayName:self.displayName sessionMode:GKSessionModeClient];
        self.session.delegate = self;
        self.session.available = YES;
	}
}

//------------------------------------------------------------------------------
- (void)connectToServerWithPeerID:(NSString*)peerID {
	self.clientState = ClientStateConnecting;
	self.serverPeerID = peerID;
	[self.session connectToPeer:peerID withTimeout:self.session.disconnectTimeout];
}

//------------------------------------------------------------------------------
// GKSessionDelegate
//------------------------------------------------------------------------------
- (void)session:(GKSession*)session peer:(NSString*)peerID didChangeState:(GKPeerConnectionState)state {
	switch (state) {
        // The client has discovered a new server.
		case GKPeerStateAvailable:
			if (self.clientState == ClientStateSearchingForServers) {
				if (![self.availableServers containsObject:peerID]) {
					[self.availableServers addObject:peerID];
					[self.delegate matchmakingClient:self serverBecameAvailable:peerID];
				}
			}
			break;
            
        // The client sees that a server goes away.
		case GKPeerStateUnavailable:
			if (self.clientState == ClientStateSearchingForServers)  {
				if ([self.availableServers containsObject:peerID]) {
					[self.availableServers removeObject:peerID];
					[self.delegate matchmakingClient:self serverBecameUnavailable:peerID];
				}
			}
            
            // Is this the server we're currently trying to connect with?
			if (self.clientState == ClientStateConnecting && [peerID isEqualToString:self.serverPeerID]) {
				[self disconnectFromServer];
			}
			break;
            
        // You're now connected to the server.
        case GKPeerStateConnected:
			if (self.clientState == ClientStateConnecting) {
				self.clientState = ClientStateConnected;
				[self.delegate matchmakingClient:self didConnectToServer:peerID];
			}
			break;
            
        // You're now no longer connected to the server.
		case GKPeerStateDisconnected:
			if (self.clientState == ClientStateConnected) {
				[self disconnectFromServer];
			}
			break;
            
		case GKPeerStateConnecting:
			break;
	}
}

//------------------------------------------------------------------------------
- (void)session:(GKSession*)session didReceiveConnectionRequestFromPeer:(NSString*)peerID {
    
}

//------------------------------------------------------------------------------
- (void)session:(GKSession*)session connectionWithPeerFailed:(NSString*)peerID withError:(NSError*)error {
	[self disconnectFromServer];
}

//------------------------------------------------------------------------------
- (void)session:(GKSession*)session didFailWithError:(NSError*)error {
	if ([[error domain] isEqualToString:GKSessionErrorDomain]) {
		if ([error code] == GKSessionCannotEnableError) {
			[self.delegate matchmakingClientNoNetwork:self];
			[self disconnectFromServer];
		}
	}
}

//------------------------------------------------------------------------------
- (NSUInteger)availableServerCount {
	return [self.availableServers count];
}

//------------------------------------------------------------------------------
- (NSString*)peerIDForAvailableServerAtIndex:(NSUInteger)index {
	return [self.availableServers objectAtIndex:index];
}

//------------------------------------------------------------------------------
- (NSString*)displayNameForPeerID:(NSString*)peerID {
	return [self.session displayNameForPeer:peerID];
}

//------------------------------------------------------------------------------
- (void)disconnectFromServer {
	self.clientState = ClientStateIdle;
    
	[self.session disconnectFromAllPeers];
	self.session.available = NO;
	self.session.delegate = nil;
	self.session = nil;
    
	self.availableServers = nil;
    
	[self.delegate matchmakingClient:self didDisconnectFromServer:self.serverPeerID];
	self.serverPeerID = nil;
}

@end
