//
//  RRTeamGenerator.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 6/16/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRTeamGenerator : NSObject

+ (void)generateTeams;

+ (int)numberOfRides;
+ (int)maximumNumberOfRidesPerRider;
+ (int)calculatedNumberOfTeams;

@end
