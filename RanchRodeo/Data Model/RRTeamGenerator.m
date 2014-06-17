//
//  RRTeamGenerator.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 6/16/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRTeamGenerator.h"

@implementation RRTeamGenerator

+ (NSArray *)generateTeams
{
    // delete teams
    [RRDataManager deleteTeams];
    
    // create teams
    int numberOfTeams = [RRUtilities numberOfTeams:[RRDataManager allRiders]];
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
    
    // preferred rules
    for (Team *team in teams)
    {
        if ([RRUtilities highestTeamNumberForRider:rider] > 0 && team.number.intValue - [RRUtilities highestTeamNumberForRider:rider] < 2)
        {
            continue;
        }
        
        if (team.riders.count > 4) {
            continue;
        }
        
        if ([rider.teams containsObject:team])
        {
            continue;
        }
        
        return team;
    }
    
    // mandatory rules
    for (Team *team in teams)
    {
        if (team.riders.count > 4) {
            continue;
        }
        
        if ([rider.teams containsObject:team])
        {
            continue;
        }
        
        return team;
    }
    
    return nil;
}

@end
