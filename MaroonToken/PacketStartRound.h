//
//  PacketStartRound.h
//  MaroonToken
//

#import "Packet.h"
#import "Round.h"

@interface PacketStartRound : Packet

@property (nonatomic, strong) Round *round;

+ (id)packetWithRound:(Round *)round;

@end
