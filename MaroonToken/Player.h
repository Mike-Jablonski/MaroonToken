//
//  Player.h
//  MaroonToken
//
//  Created by Mike Jablonski on 9/3/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//


typedef enum {
	PlayerPositionNone
}
PlayerPosition;

@interface Player : NSObject

@property (nonatomic, assign) PlayerPosition position;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* peerID;
@property (nonatomic, assign) int groupID;
@property (nonatomic, assign) int groupSize;
@property (nonatomic, assign) BOOL receivedResponse;
@property (nonatomic, assign) BOOL finishedRound;
@property (nonatomic, assign) BOOL finishedResults;
@property (nonatomic, assign) int lastPacketNumberReceived;
@property (nonatomic, assign) int gamesWon;

@property (nonatomic, copy) NSMutableArray* roundGiveTokens;
@property (nonatomic, copy) NSMutableArray* roundTakeTokens;
@property (nonatomic, copy) NSMutableArray* roundPrivateTokens;
@property (nonatomic, copy) NSMutableArray* roundGroupTokens;
@property (nonatomic, copy) NSMutableArray* roundEarningsTokens;

@end
