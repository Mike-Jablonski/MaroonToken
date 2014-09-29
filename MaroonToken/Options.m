//
//  Options.m
//  MaroonToken
//
//  Created by Mike Jablonski on 8/31/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import "Options.h"

@implementation Options

NSString * const EXPERIMENT_ID = @"experiment_id";

NSString * const TOKEN_PRIVATE_INITIAL = @"token_private_initial";
NSString * const TOKEN_PRIVATE_VISIBLE = @"token_private_visible";
NSString * const TOKEN_GROUP_INITIAL = @"token_group_initial";
NSString * const TOKEN_GROUP_VISIBLE = @"token_group_visible";

NSString * const MULTIPLIERS_PRIVATE = @"multipliers_private";
NSString * const MULTIPLIERS_PRIVATE_VISIBLE = @"multipliers_private_visible";
NSString * const MULTIPLIERS_GROUP = @"multipliers_group";
NSString * const MULTIPLIERS_GROUP_VISIBLE = @"multipliers_group_visible";

NSString * const MAXIMUM_GIVEGROUP = @"maximum_givegroup";
NSString * const MAXIMUM_TAKEGROUP = @"maximum_takegroup";

NSString * const TOKEN_CENTVALUE = @"token_centvalue";

NSString * const TIME_ROUNDSECONDS = @"time_roundseconds";
NSString * const TIME_RESULTSECONDS = @"time_resultseconds";

NSString * const ROUNDS = @"rounds";

//------------------------------------------------------------------------------
+ (void)setDefaultsIfNeeded {
    if ([self getBOOL:@"options_ready"]) {
        return;
    }

    [self setString:EXPERIMENT_ID withValue:@"Experiment-1"];
    
    [self setNumber:TOKEN_PRIVATE_INITIAL withValue:@100];
    [self setBOOL:TOKEN_PRIVATE_VISIBLE withValue:TRUE];
    [self setNumber:TOKEN_GROUP_INITIAL withValue:@0];
    [self setBOOL:TOKEN_GROUP_VISIBLE withValue:TRUE];
    
    [self setNumber:MULTIPLIERS_PRIVATE withValue:@1];
    [self setBOOL:MULTIPLIERS_PRIVATE_VISIBLE withValue:TRUE];
    [self setNumber:MULTIPLIERS_GROUP withValue:@3];
    [self setBOOL:MULTIPLIERS_GROUP_VISIBLE withValue:TRUE];
    
    [self setNumber:MAXIMUM_GIVEGROUP withValue:@100];
    [self setNumber:MAXIMUM_TAKEGROUP withValue:@0];
    
    [self setNumber:TOKEN_CENTVALUE withValue:@1];
    
    [self setNumber:TIME_ROUNDSECONDS withValue:@30];
    [self setNumber:TIME_RESULTSECONDS withValue:@45];
    
    [self setNumber:ROUNDS withValue:@3];
    
    [self setBOOL:@"options_ready" withValue:TRUE];
}

//------------------------------------------------------------------------------
+ (void)setBOOL:(NSString*)key withValue:(BOOL)value {
    NSString* stringValue = value ? @"true" : @"false";
    
    [[NSUserDefaults standardUserDefaults] setObject:stringValue forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//------------------------------------------------------------------------------
+ (BOOL)getBOOL:(NSString*)key {
    NSString* stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    return [stringValue isEqualToString:@"true"];
}

//------------------------------------------------------------------------------
+ (void)setNumber:(NSString*)key withValue:(NSNumber*)value {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//------------------------------------------------------------------------------
+ (NSNumber*)getNumber:(NSString*)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

//------------------------------------------------------------------------------
+ (void)setString:(NSString*)key withValue:(NSString*)value {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//------------------------------------------------------------------------------
+ (NSString*)getString:(NSString*)key {
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

//------------------------------------------------------------------------------
+ (void)setParticipants:(NSArray*)participants {
    [[NSUserDefaults standardUserDefaults] setObject:participants forKey:@"participants"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//------------------------------------------------------------------------------
+ (NSArray*)getParticipants {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"participants"];
}

//------------------------------------------------------------------------------
+ (void)setParticipantID:(NSString*)participantID {
    [[NSUserDefaults standardUserDefaults] setObject:participantID forKey:@"participantID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//------------------------------------------------------------------------------
+ (NSString*)getParticipantID {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"participantID"];
}

@end
