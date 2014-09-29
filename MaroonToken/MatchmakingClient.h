//
//  MatchmakingClient.h
//  MaroonToken
//

#import <GameKit/GameKit.h>

@class MatchmakingClient;

@protocol MatchmakingClientDelegate <NSObject>

- (void)matchmakingClient:(MatchmakingClient*)client serverBecameAvailable:(NSString*)peerID;
- (void)matchmakingClient:(MatchmakingClient*)client serverBecameUnavailable:(NSString*)peerID;
- (void)matchmakingClient:(MatchmakingClient*)client didDisconnectFromServer:(NSString*)peerID;
- (void)matchmakingClientNoNetwork:(MatchmakingClient*)client;
- (void)matchmakingClient:(MatchmakingClient*)client didConnectToServer:(NSString*)peerID;

@end


@interface MatchmakingClient : NSObject <GKSessionDelegate>

@property (nonatomic, strong) NSMutableArray* availableServers;
@property (nonatomic, strong) GKSession* session;
@property (nonatomic, weak) id <MatchmakingClientDelegate> delegate;
@property (nonatomic, copy) NSString* displayName;

- (void)startSearchingForServersWithSessionID:(NSString*)sessionID;
- (NSUInteger)availableServerCount;
- (NSString*)peerIDForAvailableServerAtIndex:(NSUInteger)index;
- (NSString*)displayNameForPeerID:(NSString*)peerID;
- (void)connectToServerWithPeerID:(NSString*)peerID;
- (void)disconnectFromServer;

@end
