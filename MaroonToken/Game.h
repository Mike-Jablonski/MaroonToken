//
//  Game.h
//  MaroonToken
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#import "Player.h"
#import "Round.h"

typedef enum
{
	QuitReasonNoNetwork,          // No Wi-Fi or Bluetooth
	QuitReasonConnectionDropped,  // Communication failure with server
	QuitReasonUserQuit,           // The user terminated the connection
	QuitReasonServerQuit,         // The server quit the game (on purpose)
}
QuitReason;

typedef enum
{
	GameStateWaitingForSignIn,
	GameStateWaitingForReady,
	GameStateDealing,
	GameStatePlaying,
	GameStateGameOver,
	GameStateQuitting,
    GameStateInRound,
    GameStateInResults,
}
GameState;

@class Game;

@protocol GameDelegate <NSObject>

- (void)gameWaitingForClientsReady:(Game*)game;  // Server only
- (void)gameWaitingForServerReady:(Game*)game;   // Clients only

- (void)startViewingResults:(Game*)game myPlayer:(Player*)myplayer;
- (void)stopViewingResults:(Game*)game;
- (void)startViewingRound:(Game*)game;
- (void)stopViewingRound:(Game*)game;

- (void)game:(Game*)game didQuitWithReason:(QuitReason)reason;

@end


@interface Game : NSObject <GKSessionDelegate>

@property (nonatomic, weak) id <GameDelegate> delegate;
@property (nonatomic, assign) GameState state;
@property (nonatomic, strong) Round* round;
@property (nonatomic, assign) BOOL isServer;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, assign) NSInteger roundNum;
@property (nonatomic, copy) NSMutableDictionary* participantGroupDict;
@property (nonatomic, copy) NSMutableArray* groupIDList;
@property (nonatomic, strong) NSMutableDictionary* players;

- (void)startServerGameWithSession:(GKSession*)session playerName:(NSString*)name clients:(NSArray*)clients;
- (void)startClientGameWithSession:(GKSession*)session playerName:(NSString*)name server:(NSString*)peerID;
- (void)quitGameWithReason:(QuitReason)reason;
- (void)endRoundClientWithTakeGive:(NSInteger)takes gives:(NSInteger)gives;
- (void)endResultsClient;

- (void)startRoundServer;
- (void)startRoundClient;
- (void)startResultsClient;
- (void)stopRoundClient;
- (void)stopResultsClient;
- (Player*)playerWithPeerID:(NSString*)peerID;

+ (Game*)sharedInstance;
- (BOOL)hasSession;

@end
