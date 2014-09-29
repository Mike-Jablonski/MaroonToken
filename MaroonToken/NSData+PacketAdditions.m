//
//  NSData+PacketAdditions.m
//  MaroonToken
//

#import "NSData+PacketAdditions.h"

@implementation NSData (PacketAdditions)

- (int)mt_int32AtOffset:(size_t)offset {
	const int *intBytes = (const int *)[self bytes];
	return ntohl(intBytes[offset / 4]);
}

- (short)mt_int16AtOffset:(size_t)offset {
	const short *shortBytes = (const short *)[self bytes];
	return ntohs(shortBytes[offset / 2]);
}

- (char)mt_int8AtOffset:(size_t)offset {
	const char *charBytes = (const char *)[self bytes];
	return charBytes[offset];
}

- (NSString *)mt_stringAtOffset:(size_t)offset bytesRead:(size_t *)amount {
	const char *charBytes = (const char *)[self bytes];
	NSString *string = [NSString stringWithUTF8String:charBytes + offset];
	*amount = strlen(charBytes + offset) + 1;
	return string;
}

@end


@implementation NSMutableData (PacketAdditions)

- (void)mt_appendInt32:(int)value {
	value = htonl(value);
	[self appendBytes:&value length:4];
}

- (void)mt_appendInt16:(short)value {
	value = htons(value);
	[self appendBytes:&value length:2];
}

- (void)mt_appendInt8:(char)value {
	[self appendBytes:&value length:1];
}

- (void)mt_appendString:(NSString *)string {
	const char *cString = [string UTF8String];
	[self appendBytes:cString length:strlen(cString) + 1];
}

@end
