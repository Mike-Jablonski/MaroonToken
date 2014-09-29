//
//  NSData+PacketAdditions.h
//  MaroonToken
//

@interface NSData (PacketAdditions)

- (int)mt_int32AtOffset:(size_t)offset;
- (short)mt_int16AtOffset:(size_t)offset;
- (char)mt_int8AtOffset:(size_t)offset;
- (NSString *)mt_stringAtOffset:(size_t)offset bytesRead:(size_t*)amount;

@end


@interface NSMutableData (PacketAdditions)

- (void)mt_appendInt32:(int)value;
- (void)mt_appendInt16:(short)value;
- (void)mt_appendInt8:(char)value;
- (void)mt_appendString:(NSString*)string;

@end
