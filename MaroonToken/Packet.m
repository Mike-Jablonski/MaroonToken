//
//  Packet.m
//  MaroonToken
//

#import "Packet.h"
#import "PacketOtherClientQuit.h"
#import "PacketServerReady.h"
#import "PacketSignInResponse.h"
#import "PacketStartRound.h"
#import "PacketClientEndRound.h"
#import "PacketStartResults.h"
#import "NSData+PacketAdditions.h"

const size_t PACKET_HEADER_SIZE = 10;

@implementation Packet

+ (id)packetWithType:(PacketType)packetType {
	return [[[self class] alloc] initWithType:packetType];
}

- (id)initWithType:(PacketType)packetType {
	if ((self = [super init])) {
		self.packetNumber = -1;
		self.packetType = packetType;
		self.sendReliably = YES;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data {
	if ([data length] < PACKET_HEADER_SIZE) {
		NSLog(@"Error: Packet too small");
		return nil;
	}

	if ([data mt_int32AtOffset:0] != 'TAMU') {
		NSLog(@"Error: Packet has invalid header");
		return nil;
	}

	int packetNumber = [data mt_int32AtOffset:4];
	PacketType packetType = [data mt_int16AtOffset:8];

	Packet *packet;

	switch (packetType) {
		case PacketTypeSignInRequest:
		case PacketTypeClientReady:
		case PacketTypeServerQuit:
		case PacketTypeClientQuit:
        case PacketTypeClientEndResults:
			packet = [Packet packetWithType:packetType];
			break;

		case PacketTypeSignInResponse:
			packet = [PacketSignInResponse packetWithData:data];
			break;

		case PacketTypeServerReady:
			packet = [PacketServerReady packetWithData:data];
			break;
            
        case PacketTypeStartRound:
			packet = [PacketStartRound packetWithData:data];
			break;
        
        case PacketTypeClientEndRound:
			packet = [PacketClientEndRound packetWithData:data];
			break;
        
        case PacketTypeStartResults:
			packet = [PacketStartResults packetWithData:data];
			break;
		
        case PacketTypeOtherClientQuit:
			packet = [PacketOtherClientQuit packetWithData:data];
			break;

		default:
			NSLog(@"Error: Packet has invalid type");
			return nil;
	}

	packet.packetNumber = packetNumber;
	return packet;
}

- (NSData *)data {
	NSMutableData *data = [[NSMutableData alloc] initWithCapacity:100];

	[data mt_appendInt32:'TAMU'];   // 0x534E4150
	[data mt_appendInt32:self.packetNumber];
	[data mt_appendInt16:self.packetType];

	[self addPayloadToData:data];
	return data;
}

- (void)addPayloadToData:(NSMutableData *)data {
	// base class does nothing
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ number=%d, type=%d", [super description], self.packetNumber, self.packetType];
}

@end
