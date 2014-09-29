//
//  Packet.h
//  MaroonToken
//

typedef enum
{
	PacketTypeSignInRequest = 0x64,    // server to client
	PacketTypeSignInResponse,          // client to server

	PacketTypeServerReady,             // server to client
	PacketTypeClientReady,             // client to server

    PacketTypeStartRound,              // server to client
    PacketTypeClientEndRound,          // client to server
    
    PacketTypeStartResults,            // server to client
    PacketTypeClientEndResults,        // client to server
    
	PacketTypeOtherClientQuit,         // server to client
	PacketTypeServerQuit,              // server to client
	PacketTypeClientQuit,              // client to server
}
PacketType;

const size_t PACKET_HEADER_SIZE;

@interface Packet : NSObject

@property (nonatomic, assign) int packetNumber;
@property (nonatomic, assign) PacketType packetType;
@property (nonatomic, assign) BOOL sendReliably;

+ (id)packetWithType:(PacketType)packetType;
- (id)initWithType:(PacketType)packetType;

+ (id)packetWithData:(NSData *)data;

- (NSData *)data;

@end
