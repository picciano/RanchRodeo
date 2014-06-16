//
//  RRUtilities.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/23/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRUtilities.h"

@implementation RRUtilities

static NSNumberFormatter *f;
static const float kNumberOfRidersPerTeam = 4.0f;

+ (NSString *)stringFromNumber:(NSNumber *)number
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterNoStyle];
        [f setMaximumFractionDigits:0];
    });
    
    return [f stringFromNumber:number];
}

+ (NSString *)stringFromDouble:(double)value
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterNoStyle];
        [f setMaximumFractionDigits:0];
    });
    
    return [f stringFromNumber:[NSNumber numberWithDouble:value]];
}

+ (NSNumber *)numberFromString:(NSString *)string
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterNoStyle];
        [f setMaximumFractionDigits:0];
    });
    
    return [f numberFromString:string];
}

+ (int)numberOfRides:(NSArray *)riders
{
    int numberOfRides = 0;
    
    for (Rider *rider in riders)
    {
        numberOfRides += [rider.numberOfRides intValue];
    }
    
    return numberOfRides;
}

+ (int)maximumNumberOfRides:(NSArray *)riders
{
    int maximumNumberOfRides = 0;
    
    for (Rider *rider in riders)
    {
        maximumNumberOfRides = MAX(maximumNumberOfRides, [rider.numberOfRides intValue]);
    }
    
    return maximumNumberOfRides;
}

+ (int)numberOfTeams:(NSArray *)riders
{
    float numberOfRides = [self numberOfRides:riders];
    float numberOfTeams = numberOfRides / kNumberOfRidersPerTeam;
    return MAX(ceil(numberOfTeams), [RRUtilities maximumNumberOfRides:riders]);
}

@end
