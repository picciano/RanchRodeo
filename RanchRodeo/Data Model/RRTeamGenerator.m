//
//  RRTeamGenerator.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 6/16/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRTeamGenerator.h"

@implementation RRTeamGenerator

int const kMaxRidersPerTeam = 4;
int const kMinimumWaitBetweenRides = 3;
int const kPreferredWaitBetweenRides = 5;

+ (NSArray *)generateTeams
{
    // delete teams
    [RRDataManager deleteTeams];
    
    // create teams
    int numberOfTeams = [RRTeamGenerator calculatedNumberOfTeamsForRiders:[RRDataManager allRiders]];
    for (int i=0; i < numberOfTeams; i++)
    {
        Team *team = [RRDataManager createTeam];
        [team setNumber:[NSNumber numberWithInt:i+1]];
    }
    
    BOOL success = [RRDataManager save];
    if (!success)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Teams could not be created." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
    }
    
    // add children and their parents to teams
    [self processChildren];
    
    // add ropers to teams
    // add new riders to teams
    // add everyone else to teams
    
    return [RRDataManager allWarnings];;
}

+ (void)processChildren
{
    NSArray *children = [RRDataManager allChildRiders];
    
    for (Rider *child in children)
    {
        NSArray *parents = [child.parents sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
        
        for (int i = 0; i < child.numberOfRides.intValue; i++)
        {
            Team *team = [self findTeamForRider:child];
            [team addRidersObject:child];
            
            Rider *parent = [parents objectAtIndex:i % parents.count];
            if (parent.teams.count >= parent.numberOfRides.intValue)
            {
                continue;
            }
            [team addRidersObject:parent];
        }
    }
    
    BOOL success = [RRDataManager save];
    if (!success)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Teams could not be created for children." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
    }
}

+ (Team *)findTeamForRider:(Rider *)rider
{
    NSArray *teams = [RRDataManager allTeams];
    NSMutableArray *potentialTeams = [NSMutableArray arrayWithCapacity:teams.count];
    NSMutableArray *preferredTeams = [NSMutableArray arrayWithCapacity:teams.count];
    
    // mandatory rules
    for (Team *team in teams)
    {
        if (team.riders.count >= kMaxRidersPerTeam)
        {
            continue;
        }
        
        if ([rider.teams containsObject:team])
        {
            continue;
        }
        
        [potentialTeams addObject:team];
    }
    
    // preferred rules
    for (Team *team in potentialTeams)
    {
        if ([RRTeamGenerator highestTeamNumberForRider:rider] > 0 &&
            team.number.intValue - [RRTeamGenerator highestTeamNumberForRider:rider] < kMinimumWaitBetweenRides)
        {
            continue;
        }
        
        if (rider.isChild && [RRTeamGenerator hasChildOnTeam:team])
        {
            continue;
        }
        
        [preferredTeams addObject:team];
    }
    
    // optional rules
    for (Team *team in preferredTeams)
    {
        if ([RRTeamGenerator highestTeamNumberForRider:rider] > 0 &&
            team.number.intValue - [RRTeamGenerator highestTeamNumberForRider:rider] < kPreferredWaitBetweenRides)
        {
            continue;
        }
        
        return team;
    }
    
    // teams fails optional rules, return first result from preferred teams
    if (preferredTeams.count > 0)
    {
        return [preferredTeams objectAtIndex:0];
    }
    
    // teams failed preferred rules, return first result from potential teams
    if (potentialTeams.count > 0)
    {
        return [potentialTeams objectAtIndex:0];
    }
    
    return nil;
}

+ (BOOL)hasChildOnTeam:(Team *)team
{
    for (Rider *rider in team.riders.allObjects)
    {
        if (rider.isChild) {
            return YES;
        }
    }
    return NO;
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

+ (int)calculatedNumberOfTeamsForRiders:(NSArray *)riders
{
    float numberOfRides = [self numberOfRides:riders];
    float numberOfTeams = numberOfRides / kMaxRidersPerTeam;
    return MAX(ceil(numberOfTeams), [RRTeamGenerator maximumNumberOfRides:riders]);
}

+ (int)highestTeamNumberForRider:(Rider *)rider
{
    int highestTeamNumberForRider = 0;
    
    for (Team *team in rider.teams.allObjects)
    {
        highestTeamNumberForRider = MAX(highestTeamNumberForRider, [team.number intValue]);
    }
    
    return highestTeamNumberForRider;
}

@end
