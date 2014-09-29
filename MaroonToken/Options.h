//
//  Options.h
//  MaroonToken
//
//  Created by Mike Jablonski on 8/31/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Options : NSObject

extern NSString* const EXPERIMENT_ID;

extern NSString* const TOKEN_PRIVATE_INITIAL;
extern NSString* const TOKEN_PRIVATE_VISIBLE;
extern NSString* const TOKEN_GROUP_INITIAL;
extern NSString* const TOKEN_GROUP_VISIBLE;

extern NSString* const MULTIPLIERS_PRIVATE;
extern NSString* const MULTIPLIERS_PRIVATE_VISIBLE;
extern NSString* const MULTIPLIERS_GROUP;
extern NSString* const MULTIPLIERS_GROUP_VISIBLE;

extern NSString* const MAXIMUM_GIVEGROUP;
extern NSString* const MAXIMUM_TAKEGROUP;

extern NSString* const TOKEN_CENTVALUE;

extern NSString* const TIME_ROUNDSECONDS;
extern NSString* const TIME_RESULTSECONDS;

extern NSString* const ROUNDS;


+ (void)setDefaultsIfNeeded;

+ (void)setBOOL:(NSString*)key withValue:(BOOL)value;
+ (BOOL)getBOOL:(NSString*)key;

+ (void)setNumber:(NSString*)key withValue:(NSNumber*)value;
+ (NSNumber*)getNumber:(NSString*)key;

+ (void)setString:(NSString*)key withValue:(NSString*)value;
+ (NSString*)getString:(NSString*)key;

+ (void)setParticipants:(NSArray*)participants;
+ (NSArray*)getParticipants;

+ (void)setParticipantID:(NSString*)participantID;
+ (NSString*)getParticipantID;

@end
