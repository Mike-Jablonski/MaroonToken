//
//  PacketStartResults.h
//  MaroonToken
//

#import "Packet.h"

@interface PacketStartResults : Packet

@property (nonatomic, strong) NSArray* roundGroupTokens;

+ (id)packetWithTokens:(NSArray *)roundGroupTokens;

@end
