//
//  PacketOtherClientQuit.m
//  MaroonToken
//

#import "PacketOtherClientQuit.h"
#import "NSData+PacketAdditions.h"

@implementation PacketOtherClientQuit

+ (id)packetWithPeerID:(NSString *)peerID cards:(NSDictionary *)cards {
	return [[[self class] alloc] initWithPeerID:peerID cards:cards];
}

- (id)initWithPeerID:(NSString *)peerID cards:(NSDictionary *)cards {
	if ((self = [super initWithType:PacketTypeOtherClientQuit])) {
		self.peerID = peerID;
		self.cards = cards;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data {
	return 0;
}

- (void)addPayloadToData:(NSMutableData *)data {

}

@end
