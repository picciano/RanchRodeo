//
//  Rider+Category.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/23/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "Rider+Category.h"
#import "RRTeamGenerator.h"

@implementation Rider (Category)

NSString * const kRiderCategoryChild = @"K";
NSString * const kRiderCategoryParent = @"P";
NSString * const kRiderCategoryRoper = @"R";
NSString * const kRiderCategoryNewRider = @"N";
NSString * const kRiderCategoryGeneral = @"G";

- (NSString *)category
{
    NSMutableString *category = [[NSMutableString alloc] init];
    
    if ([[self isChild] boolValue]) {
        [category appendString:kRiderCategoryChild];
    }
    
    if ([[self isParent] boolValue]) {
        [category appendString:kRiderCategoryParent];
    }

    if ([[self isRoper] boolValue]) {
        [category appendString:kRiderCategoryRoper];
    }
    
    if ([[self isNewRider] boolValue]) {
        [category appendString:kRiderCategoryNewRider];
    }
    
    if ([category length] == 0)
    {
        [category appendString:kRiderCategoryGeneral];
    }
    
    return category;
}

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (BOOL)hasTeamWithNumberWithin:(int)numberOfRides ofTeamNumber:(int)teamNumber
{
    for (Team *team in self.teams.allObjects)
    {
        if (abs(teamNumber - team.number.intValue) < numberOfRides)
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)hasRequestedExtraRides
{
    return [[self numberOfRides] intValue] > 2;
}

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"%@ (%i %@)", self.fullName, self.numberOfRides.intValue, self.category];
    return description;
}

@end
