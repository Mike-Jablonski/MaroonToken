//
//  PacketClientEndRound.m
//  MaroonToken
//

#import "PacketClientEndRound.h"
#import "NSData+PacketAdditions.h"

@implementation PacketClientEndRound

+ (id)packetWithTokens:(int)roundTakeTokens roundGiveTokens:(int)roundGiveTokens {
	return [[[self class] alloc] initWithTokens:roundTakeTokens roundGiveTokens:roundGiveTokens];
}

- (id)initWithTokens:(int)roundTakeTokens roundGiveTokens:(int)roundGiveTokens {
	if ((self = [super initWithType:PacketTypeClientEndRound])) {
		self.roundTakeTokens = roundTakeTokens;
		self.roundGiveTokens = roundGiveTokens;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data {
    size_t offset = PACKET_HEADER_SIZE;
    
    offset += 2; //Junk to make Int32 work.
    
	int roundTakeTokens = [data mt_int32AtOffset:offset];
    offset += 4;
    
	int roundGiveTokens = [data mt_int32AtOffset:offset];
    
    return [[self class] packetWithTokens:roundTakeTokens roundGiveTokens:roundGiveTokens];
}

- (void)addPayloadToData:(NSMutableData *)data {
    [data mt_appendInt16:0]; //Junk to make Int32 work.
    [data mt_appendInt32:self.roundTakeTokens];
    [data mt_appendInt32:self.roundGiveTokens];
}

@end
