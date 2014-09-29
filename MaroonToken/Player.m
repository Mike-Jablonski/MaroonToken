//
//  Player.m
//  MaroonToken
//
//  Created by Mike Jablonski on 9/3/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "Player.h"

@implementation Player

//------------------------------------------------------------------------------
- (id)init {
	if ((self = [super init])) {
		_lastPacketNumberReceived = -1;
        _roundGiveTokens = [NSMutableArray array];
        _roundTakeTokens = [NSMutableArray array];
        _roundPrivateTokens= [NSMutableArray array];
        _roundGroupTokens= [NSMutableArray array];
        _roundEarningsTokens = [NSMutableArray array];
        
        _groupID = 0;
        _groupSize = 2;
	}
	return self;
}

//------------------------------------------------------------------------------
- (NSString*)description {
	return [NSString stringWithFormat:@"%@ peerID = %@, name = %@, position = %d", [super description], self.peerID, self.name, self.position];
}

@end
