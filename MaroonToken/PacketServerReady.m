//
//  PacketServerReady.m
//  MaroonToken
//

#import "PacketServerReady.h"
#import "NSData+PacketAdditions.h"
#import "Player.h"

@implementation PacketServerReady

+ (id)packetWithPlayers:(NSMutableDictionary *)players {
	return [[[self class] alloc] initWithPlayers:players];
}

- (id)initWithPlayers:(NSMutableDictionary *)players {
	if ((self = [super initWithType:PacketTypeServerReady])) {
		self.players = players;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data {
	NSMutableDictionary *players = [NSMutableDictionary dictionaryWithCapacity:10];
    
	size_t offset = PACKET_HEADER_SIZE;
	size_t count;
    
    
	int numberOfPlayers = [data mt_int16AtOffset:offset];
	offset += 2;
    
	for (int t = 0; t < numberOfPlayers; ++t) {
		NSString *peerID = [[data mt_stringAtOffset:offset bytesRead:&count] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		offset += count;
        
		NSString *name = [[data mt_stringAtOffset:offset bytesRead:&count] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		offset += count;
        
		PlayerPosition position = [data mt_int8AtOffset:offset];
		offset += 4;
        
        int groupID = [data mt_int32AtOffset:offset];
        offset += 4;
        
        int groupSize = [data mt_int32AtOffset:offset];
        offset += 4;
        
		Player *player = [[Player alloc] init];
		player.peerID = peerID;
		player.name = name;
		player.position = position;
        player.groupID = groupID;
        player.groupSize = groupSize;
		[players setObject:player forKey:player.peerID];
	}
    
	return [[self class] packetWithPlayers:players];
}

- (void)addPayloadToData:(NSMutableData *)data {
    //Make the strings in increments of 4 bytes.
    NSString *oneSpace = @" ";
    NSString *twoSpace = @"  ";
    NSString *threeSpace = @"   ";
    
    [data mt_appendInt16:[self.players count]];
    
    [self.players enumerateKeysAndObjectsUsingBlock:^(id key, Player *player, BOOL *stop) {
         const char *cPeerID = [player.peerID UTF8String];
         NSString *sizedPeerID;
         switch ((strlen(cPeerID) + 1) % 4) {
             case 1:
                 sizedPeerID = [NSString stringWithFormat:@"%@%@", player.peerID, threeSpace];
                 break;
             case 2:
                 sizedPeerID = [NSString stringWithFormat:@"%@%@", player.peerID, twoSpace];
                 break;
             case 3:
                 sizedPeerID = [NSString stringWithFormat:@"%@%@", player.peerID, oneSpace];
                 break;
                 
             default:
                 sizedPeerID = [NSString stringWithFormat:@"%@", player.peerID];
                 break;
         }
         
         const char *cName = [player.name UTF8String];
         NSString *sizedName;
         switch ((strlen(cName) + 1) % 4) {
             case 1:
                 sizedName = [NSString stringWithFormat:@"%@%@", player.name, threeSpace];
                 break;
             case 2:
                 sizedName = [NSString stringWithFormat:@"%@%@", player.name, twoSpace];
                 break;
             case 3:
                 sizedName = [NSString stringWithFormat:@"%@%@", player.name, oneSpace];
                 break;
                 
             default:
                 sizedName = [NSString stringWithFormat:@"%@", player.name];
                 break;
         }
         
         [data mt_appendString:sizedPeerID];
         [data mt_appendString:sizedName];
         [data mt_appendInt32:player.position];
         [data mt_appendInt32:player.groupID];
         [data mt_appendInt32:player.groupSize];
     }];
}

@end
