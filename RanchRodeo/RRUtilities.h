//
//  RRUtilities.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/23/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRUtilities : NSObject

+ (NSString *)stringFromNumber:(NSNumber *)number;
+ (NSString *)stringFromDouble:(double)value;
+ (NSNumber *)numberFromString:(NSString *)string;
+ (int)numberOfRides:(NSArray *)riders;
+ (int)maximumNumberOfRides:(NSArray *)riders;
+ (int)numberOfTeams:(NSArray *)riders;
+ (int)highestTeamNumberForRider:(Rider *)rider;

@end
