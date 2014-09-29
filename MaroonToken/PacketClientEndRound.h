//
//  PacketClientEndRound.h
//  MaroonToken
//

#import "Packet.h"

@interface PacketClientEndRound : Packet

@property (nonatomic, assign) int roundTakeTokens;
@property (nonatomic, assign) int roundGiveTokens;

+ (id)packetWithTokens:(int)roundTakeTokens roundGiveTokens:(int)roundGiveTokens;

@end
