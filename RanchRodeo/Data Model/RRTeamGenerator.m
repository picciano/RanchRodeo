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

+ (void)generateTeams
{
    // delete teams
    [RRDataManager deleteTeams];
    
    // create teams
    int numberOfTeams = [RRTeamGenerator calculatedNumberOfTeams];
    for (int i = 0; i < numberOfTeams; i++)
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
    [self processRiders:[RRDataManager allChildRiders]];
    
    // add ropers to teams
    [self processRiders:[RRDataManager allRopers]];
    
    // add new riders to teams
    [self processRiders:[RRDataManager allNewRiders]];
    
    // add everyone else to teams
    [self processRiders:[RRDataManager allRiders]];
    
    // check for team warnings
    [self determineWarnings];
}

+ (void)processRiders:(NSArray *)riders
{
    for (Rider *rider in riders)
    {
        NSArray *parents = [rider.parents sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
        
        for (int i = rider.teams.count; i < rider.numberOfRides.intValue; i++)
        {
            Team *team = [self findTeamForRider:rider];
            [team addRidersObject:rider];
            
            if ([[rider isChild] boolValue] && rider.parents.count > 0)
            {
                // also add parent to same team
                Rider *parent = [parents objectAtIndex:i % parents.count];
                if (parent.teams.count >= parent.numberOfRides.intValue)
                {
                    continue;
                }
                [team addRidersObject:parent];
            }
        }
    }
    
    BOOL success = [RRDataManager save];
    if (!success)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Teams could not be created." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
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
        if ([rider highestTeamNumber] > 0 &&
            team.number.intValue - [rider highestTeamNumber] < kMinimumWaitBetweenRides)
        {
            continue;
        }
        
        if ([[rider isChild] boolValue] && team.hasChildRider)
        {
            continue;
        }
        
        if ([[rider isRoper] boolValue] && team.hasRoper)
        {
            continue;
        }
        
        if ([[rider isNewRider] boolValue] && team.hasNewRider)
        {
            continue;
        }
        
        [preferredTeams addObject:team];
    }
    
    // optional rules
    for (Team *team in preferredTeams)
    {
        if ([rider highestTeamNumber] > 0 &&
            team.number.intValue - [rider highestTeamNumber] < rider.preferredWaitBetweenRides)
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

+ (void)determineWarnings
{
    NSArray *teams = [RRDataManager allTeams];
    
    for (Team *team in teams)
    {
        if (team.riders.count != 4)
        {
            Warning *warning = [RRDataManager createWarning];
            [warning setMessage:@"Team should have four riders."];
            [warning setTeam:team];
        }
        
        if (!team.allRidersHaveSignedWaiver)
        {
            Warning *warning = [RRDataManager createWarning];
            [warning setMessage:@"All riders need to sign waiver."];
            [warning setTeam:team];
        }
    }
    
    BOOL success = [RRDataManager save];
    if (!success)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Warnings could not be created." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - public methods

+ (int)numberOfRides
{
    NSArray *riders = [RRDataManager allRiders];
    int numberOfRides = 0;
    
    for (Rider *rider in riders)
    {
        numberOfRides += [rider.numberOfRides intValue];
    }
    
    return numberOfRides;
}

+ (int)maximumNumberOfRidesPerRider
{
    NSArray *riders = [RRDataManager allRiders];
    int maximumNumberOfRides = 0;
    
    for (Rider *rider in riders)
    {
        maximumNumberOfRides = MAX(maximumNumberOfRides, [rider.numberOfRides intValue]);
    }
    
    return maximumNumberOfRides;
}

+ (int)calculatedNumberOfTeams
{
    float numberOfRides = [self numberOfRides];
    float numberOfTeams = numberOfRides / kMaxRidersPerTeam;
    return MAX(ceil(numberOfTeams), [RRTeamGenerator maximumNumberOfRidesPerRider]);
}

@end
