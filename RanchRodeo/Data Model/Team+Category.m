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

@end
