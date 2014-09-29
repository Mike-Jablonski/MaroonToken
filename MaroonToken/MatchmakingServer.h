//
//  MatchmakingServer.h
//  MaroonToken
//

#import <GameKit/GameKit.h>

@class MatchmakingServer;

@protocol MatchmakingServerDelegate <NSObject>

- (void)matchmakingServer:(MatchmakingServer*)server clientDidConnect:(NSString*)peerID;
- (void)matchmakingServer:(MatchmakingServer*)server clientDidDisconnect:(NSString*)peerID;
- (void)matchmakingServer:(MatchmakingServer*)server clientDuplicate:(NSString*)peerName;
- (void)matchmakingServer:(MatchmakingServer*)server clientNotListed:(NSString*)peerNameD;
- (void)matchmakingServerSessionDidEnd:(MatchmakingServer*)server;
- (void)matchmakingServerNoNetwork:(MatchmakingServer*)server;

@end


@interface MatchmakingServer : NSObject <GKSessionDelegate>

@property (nonatomic, assign) int maxClients;
@property (nonatomic, strong) NSMutableArray* connectedClients;
@property (nonatomic, strong) GKSession* session;
@property (nonatomic, weak) id <MatchmakingServerDelegate> delegate;
@property (nonatomic, copy) NSString* displayName;
@property (nonatomic, copy) NSArray* playerList;

- (void)endSession;
- (void)startAcceptingConnectionsForSessionID:(NSString*)sessionID;
- (NSUInteger)connectedClientCount;
- (NSString*)peerIDForConnectedClientAtIndex:(NSUInteger)index;
- (NSString*)displayNameForPeerID:(NSString*)peerID;
- (void)setDisplayName:(NSString*)name;
- (void)stopAcceptingConnections;

@end
