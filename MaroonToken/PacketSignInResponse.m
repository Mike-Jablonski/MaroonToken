//
//  PacketSignInResponse.m
//  MaroonToken
//

#import "PacketSignInResponse.h"
#import "NSData+PacketAdditions.h"

@implementation PacketSignInResponse

+ (id)packetWithPlayerName:(NSString *)playerName {
	return [[[self class] alloc] initWithPlayerName:playerName];
}

- (id)initWithPlayerName:(NSString *)playerName {
	if ((self = [super initWithType:PacketTypeSignInResponse])) {
		self.playerName = playerName;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data {
	size_t count;
	NSString *playerName = [data mt_stringAtOffset:PACKET_HEADER_SIZE bytesRead:&count];
	return [[self class] packetWithPlayerName:playerName];
}

- (void)addPayloadToData:(NSMutableData *)data {
	[data mt_appendString:self.playerName];
}

@end
