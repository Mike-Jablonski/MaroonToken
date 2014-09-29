//
//  PacketStartRound.m
//  MaroonToken
//

#import "PacketStartRound.h"
#import "NSData+PacketAdditions.h"

@implementation PacketStartRound

+ (id)packetWithRound:(Round *)round {
	return [[[self class] alloc] initWithRound:round];
}

- (id)initWithRound:(Round *)round {
	if ((self = [super initWithType:PacketTypeStartRound])) {
		self.round = round;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data {
    Round *round = [[Round alloc] init];
    
	size_t offset = PACKET_HEADER_SIZE;
    size_t count;
    
    BOOL groupVisible = [data mt_int8AtOffset:offset];
    offset += 1;
    
	BOOL privateVisible = [data mt_int8AtOffset:offset];
    offset += 1;
    
    BOOL groupMultiplierVisible = [data mt_int8AtOffset:offset];
    offset += 1;
    
	BOOL privateMultiplieVisible = [data mt_int8AtOffset:offset];
    offset += 1;
    
    NSString *experimentName = [data mt_stringAtOffset:offset bytesRead:&count];
    offset += count;
    
    NSString *surveyURL = [data mt_stringAtOffset:offset bytesRead:&count];
    offset += count;
    
    int groupTokens = [data mt_int32AtOffset:offset];
    offset += 4;
    
    int privateTokens = [data mt_int32AtOffset:offset];
    offset += 4;
    
    int groupMultiplier = [data mt_int32AtOffset:offset];
    offset += 4;
    
    int privateMultiplier = [data mt_int32AtOffset:offset];
    offset += 4;
    
    int tokenToCents = [data mt_int32AtOffset:offset];
    offset += 4;
    
    int maxGive = [data mt_int32AtOffset:offset];
    offset += 4;
    
    int maxTake = [data mt_int32AtOffset:offset];
    offset += 4;
    
    int roundTime = [data mt_int32AtOffset:offset];
    offset += 4;
    
    int resultTime = [data mt_int32AtOffset:offset];
    offset += 4;
    
    int numOfRounds = [data mt_int32AtOffset:offset];
    
    round.experimentName = experimentName;
    round.surveyURL = surveyURL;
	round.groupMultiplierVisible = groupMultiplierVisible;
	round.privateMultiplieVisible = privateMultiplieVisible;
    round.groupTokens = groupTokens;
    round.privateTokens = privateTokens;
    round.groupMultiplier = (float) groupMultiplier/100.0;
    round.privateMultiplier = (float) privateMultiplier/100.0;
    round.tokenToCents = (float) tokenToCents/100.0;
    round.maxGive = maxGive;
    round.maxTake = maxTake;
    round.roundTime = roundTime;
    round.resultTime = resultTime;
    round.groupVisible = groupVisible;
	round.privateVisible = privateVisible;
    round.numOfRounds = numOfRounds;
    
	return [[self class] packetWithRound:round];
}

- (void)addPayloadToData:(NSMutableData *)data {
    int groupMultiplierInt = (int) (self.round.groupMultiplier * 100.0);
    int privateMultiplierInt = (int) (self.round.privateMultiplier * 100.0);
    int tokenToCentsInt = (int) (self.round.tokenToCents * 100.0);
    
    //Make the strings in increments of 4 bytes.
    NSString *oneSpace = @" ";
    NSString *twoSpace = @"  ";
    NSString *threeSpace = @"   ";
    
    const char *cexperimentName = [self.round.experimentName UTF8String];
    NSString *sizedexperimentName;
    switch ((strlen(cexperimentName)) % 4) {
        case 1:
            sizedexperimentName = [NSString stringWithFormat:@"%@%@", self.round.experimentName, threeSpace];
            break;
        case 2:
            sizedexperimentName = [NSString stringWithFormat:@"%@%@", self.round.experimentName, twoSpace];
            break;
        case 3:
            sizedexperimentName = [NSString stringWithFormat:@"%@%@", self.round.experimentName, oneSpace];
            break;
            
        default:
            sizedexperimentName = [NSString stringWithFormat:@"%@", self.round.experimentName];
            break;
    }
    
    const char *csurveyURL = [self.round.surveyURL UTF8String];
    NSString *sizedsurveyURL;
    switch ((strlen(csurveyURL)) % 4) {
        case 1:
            sizedsurveyURL = [NSString stringWithFormat:@"%@%@", self.round.surveyURL, threeSpace];
            break;
        case 2:
            sizedsurveyURL = [NSString stringWithFormat:@"%@%@", self.round.surveyURL, twoSpace];
            break;
        case 3:
            sizedsurveyURL = [NSString stringWithFormat:@"%@%@", self.round.surveyURL, oneSpace];
            break;
            
        default:
            sizedsurveyURL = [NSString stringWithFormat:@"%@", self.round.surveyURL];
            break;
    }
    
    [data mt_appendInt8:self.round.groupVisible];
	[data mt_appendInt8:self.round.privateVisible];
    [data mt_appendInt8:self.round.groupMultiplierVisible];
	[data mt_appendInt8:self.round.privateMultiplieVisible];
    [data mt_appendString:sizedexperimentName]; //Has extra byte at end
    [data mt_appendString:sizedsurveyURL]; //Has extra byte at end
    [data mt_appendInt32:self.round.groupTokens];
    [data mt_appendInt32:self.round.privateTokens];
    [data mt_appendInt32:groupMultiplierInt];
    [data mt_appendInt32:privateMultiplierInt];
    [data mt_appendInt32:tokenToCentsInt];
    [data mt_appendInt32:self.round.maxGive];
    [data mt_appendInt32:self.round.maxTake];
    [data mt_appendInt32:self.round.roundTime];
    [data mt_appendInt32:self.round.resultTime];
    [data mt_appendInt32:self.round.numOfRounds];
}

@end
