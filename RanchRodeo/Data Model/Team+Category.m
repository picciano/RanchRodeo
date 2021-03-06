//
//  Team+Category.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 6/17/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "Team+Category.h"

@implementation Team (Category)

- (BOOL)hasChildRider
{
    for (Rider *rider in self.riders.allObjects)
    {
        if ([[rider isChild] boolValue])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasRoper
{
    for (Rider *rider in self.riders.allObjects)
    {
        if ([[rider isRoper] boolValue])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasNewRider
{
    for (Rider *rider in self.riders.allObjects)
    {
        if ([[rider isNewRider] boolValue])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)allRidersHaveSignedWaiver
{
    for (Rider *rider in self.riders.allObjects)
    {
        if (![[rider isWaiverSigned] boolValue])
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)hasRiderWithExtraRides;
{
    for (Rider *rider in self.riders.allObjects)
    {
        if ([rider hasRequestedExtraRides])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasRider:(Rider *)rider
{
    for (Rider *otherRider in self.riders.allObjects)
    {
        if (rider == otherRider)
        {
            return YES;
        }
    }
    return NO;
}

@end
