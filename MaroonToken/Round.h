//
//  Round.h
//  MaroonToken
//
//  Created by Mike Jablonski on 9/3/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

@interface Round : NSObject

@property (nonatomic, assign) BOOL groupVisible;
@property (nonatomic, assign) BOOL privateVisible;
@property (nonatomic, assign) BOOL groupMultiplierVisible;
@property (nonatomic, assign) BOOL privateMultiplieVisible;
@property (nonatomic, assign) int groupTokens;
@property (nonatomic, assign) int privateTokens;
@property (nonatomic, assign) float groupMultiplier;
@property (nonatomic, assign) float privateMultiplier;
@property (nonatomic, assign) int maxGive;
@property (nonatomic, assign) int maxTake;
@property (nonatomic, assign) int roundTime;
@property (nonatomic, assign) int resultTime;
@property (nonatomic, assign) float tokenToCents;
@property (nonatomic, assign) int numOfRounds;
@property (nonatomic, copy) NSString* experimentName;
@property (nonatomic, copy) NSString* surveyURL;

@end
