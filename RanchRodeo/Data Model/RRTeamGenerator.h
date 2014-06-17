//
//  RRTeamGenerator.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 6/16/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRTeamGenerator : NSObject

+ (NSArray *)generateTeams;

+ (int)numberOfRides:(NSArray *)riders;
+ (int)maximumNumberOfRides:(NSArray *)riders;
+ (int)calculatedNumberOfTeamsForRiders:(NSArray *)riders;
+ (int)highestTeamNumberForRider:(Rider *)rider;

@end
