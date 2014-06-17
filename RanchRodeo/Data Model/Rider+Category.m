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

- (int)highestTeamNumber
{
    int highestTeamNumber = 0;
    
    for (Team *team in self.teams.allObjects)
    {
        highestTeamNumber = MAX(highestTeamNumber, [team.number intValue]);
    }
    
    return highestTeamNumber;
}

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"%@ (%i %@)", self.fullName, self.numberOfRides.intValue, self.category];
    return description;
}

- (int)preferredWaitBetweenRides
{
    int preferredWaitBetweenRides = 0;
    
    NSString *str = self.description;
    NSUInteger len = [str length];
    unichar buffer[len + 1];
    [str getCharacters:buffer range:NSMakeRange(0, len)];
    
    for(int i = 0; i < len; i++)
    {
        preferredWaitBetweenRides += buffer[i];
    }
    
    preferredWaitBetweenRides = (preferredWaitBetweenRides % 10) + 3;
    
    return preferredWaitBetweenRides;
}

@end
