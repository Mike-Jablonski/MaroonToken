//
//  PacketStartResults.m
//  MaroonToken
//

#import "PacketStartResults.h"
#import "NSData+PacketAdditions.h"

@implementation PacketStartResults

+ (id)packetWithTokens:(NSArray *)roundGroupTokens {
	return [[[self class] alloc] initWithTokens:roundGroupTokens];
}

- (id)initWithTokens:(NSArray *)roundGroupTokens {
	if ((self = [super initWithType:PacketTypeStartResults])) {
		self.roundGroupTokens = roundGroupTokens;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data {
    
    size_t offset = PACKET_HEADER_SIZE;
    
    int count = [data mt_int16AtOffset:offset];
    offset += 2;
    
    NSMutableArray *roundGroupTokensArray = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        [roundGroupTokensArray addObject: [NSNumber numberWithInteger:[data mt_int32AtOffset:offset]]];
        offset += 4;
    }
    
    NSArray *roundGroupTokensNSArray = [NSArray arrayWithArray:roundGroupTokensArray];
    
    return [[self class] packetWithTokens:roundGroupTokensNSArray];
}

- (void)addPayloadToData:(NSMutableData *)data {
    int count = [self.roundGroupTokens count];
    [data mt_appendInt16:count];
    
    for (int i = 0; i < count; i++) {
        [data mt_appendInt32:[[self.roundGroupTokens objectAtIndex:i] intValue]];
    }
}

@end
