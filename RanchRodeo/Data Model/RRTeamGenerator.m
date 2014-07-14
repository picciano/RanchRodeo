//
//  RRTeamGenerator.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 6/16/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRTeamGenerator.h"

@implementation RRTeamGenerator

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(RRTeamGenerator);

int const kMaxRidersPerTeam = 4;
int const kMinimumWaitBetweenRides = 2;
int const kPreferredWaitBetweenRides = 4;

- (void)generateTeams
{
    // delete teams
    [[RRDataManager sharedRRDataManager] deleteTeams];
    
    // create teams
    int numberOfTeams = [self calculatedNumberOfTeams];
    for (int i = 0; i < numberOfTeams; i++)
    {
        Team *team = [[RRDataManager sharedRRDataManager] createTeam];
        [team setNumber:[NSNumber numberWithInt:i+1]];
    }
    
    BOOL success = [[RRDataManager sharedRRDataManager] save];
    if (!success)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Teams could not be created." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
    }
    
    // add children and their parents to teams
    [self processRiders:[[RRDataManager sharedRRDataManager] allChildRiders]];
    
    // add ropers to teams
    [self processRiders:[[RRDataManager sharedRRDataManager] allRopers]];
    
    // add new riders to teams
    [self processRiders:[[RRDataManager sharedRRDataManager] allNewRiders]];
    
    // add riders with extra rides to teams
    [self processRiders:[[RRDataManager sharedRRDataManager] allRidersWithExtraRides]];
    
    // add everyone else to teams
    [self processRiders:[[RRDataManager sharedRRDataManager] allRiders]];
    
    // check for team warnings
    [self determineWarnings];
    
    [[RRDataManager sharedRRDataManager] setNeedsTeamGeneration:NO];
}

- (void)processRiders:(NSArray *)riders
{
    for (Rider *rider in riders)
    {
        NSArray *parents = [rider.parents sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
        
        for (NSUInteger i = rider.teams.count; i < rider.numberOfRides.intValue; i++)
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
    
    BOOL success = [[RRDataManager sharedRRDataManager] save];
    if (!success)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Teams could not be created." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
    }
}

- (Team *)findTeamForRider:(Rider *)rider
{
    NSArray *teams = [[RRDataManager sharedRRDataManager] allTeams];
    NSMutableArray *potentialTeams = [NSMutableArray arrayWithCapacity:teams.count];
    NSMutableArray *preferredTeams = [NSMutableArray arrayWithCapacity:teams.count];
    NSMutableArray *bestMatchTeams = [NSMutableArray arrayWithCapacity:teams.count];
    
//    NSString *riderName = rider.firstName;
    
//    NSLog(@"----------------- Finding team for %@.", riderName);
    
    // mandatory rules
    for (Team *team in teams)
    {
        if (team.riders.count >= kMaxRidersPerTeam)
        {
//            NSLog(@"%@ team %@ is full.", riderName, team.number);
            continue;
        }
        
        if ([rider.teams containsObject:team])
        {
//            NSLog(@"%@ is already on team %@.", riderName, team.number);
            continue;
        }
        
        [potentialTeams addObject:team];
    }
    
    // preferred rules
    for (Team *team in potentialTeams)
    {
        if ([rider hasTeamWithNumberWithin:kMinimumWaitBetweenRides ofTeamNumber:team.number.intValue])
        {
//            NSLog(@"%@ is within %i of team %@.", riderName, kMinimumWaitBetweenRides, team.number);
            continue;
        }
        
        if ([[rider isChild] boolValue] && team.hasChildRider)
        {
//            NSLog(@"%@ team %@ already has child rider.", riderName, team.number);
            continue;
        }
        
        if ([[rider isRoper] boolValue] && team.hasRoper)
        {
//            NSLog(@"%@ team %@ already has roper rider.", riderName, team.number);
            continue;
        }
        
        if ([[rider isNewRider] boolValue] && team.hasNewRider)
        {
//            NSLog(@"%@ team %@ already has new rider.", riderName, team.number);
            continue;
        }
        
        [preferredTeams addObject:team];
    }
    
    // optional rules
    for (Team *team in preferredTeams)
    {
        if ([rider hasRequestedExtraRides] && team.hasRiderWithExtraRides)
        {
//            NSLog(@"%@ team %@ already has rider with extra rides.", riderName, team.number);
            continue;
        }
        
        if ([rider hasTeamWithNumberWithin:kPreferredWaitBetweenRides ofTeamNumber:team.number.intValue])
        {
//            NSLog(@"%@ is within %i of team %@.", riderName, kPreferredWaitBetweenRides, team.number);
            continue;
        }
        
        [bestMatchTeams addObject:team];
    }
    
    // teams meets rules, return first result from preferred teams
    if (bestMatchTeams.count > 0)
    {
        return [self randomTeamFromArray:bestMatchTeams];
    }
    
    // teams fails optional rules, return first result from preferred teams
    if (preferredTeams.count > 0)
    {
        return [self randomTeamFromArray:preferredTeams];
    }
    
    // teams failed preferred rules, return first result from potential teams
    if (potentialTeams.count > 0)
    {
        return [self randomTeamFromArray:potentialTeams];
    }
    
    return nil;
}

- (Team *)randomTeamFromArray:(NSArray *)array
{
    return [array objectAtIndex:rand()%[array count]];
}

- (void)determineWarnings
{
    NSArray *teams = [[RRDataManager sharedRRDataManager] allTeams];
    
    for (Team *team in teams)
    {
        if (team.riders.count != 4)
        {
            Warning *warning = [[RRDataManager sharedRRDataManager] createWarning];
            [warning setMessage:@"Team should have four riders."];
            [warning setTeam:team];
        }
        
        if (!team.allRidersHaveSignedWaiver)
        {
            Warning *warning = [[RRDataManager sharedRRDataManager] createWarning];
            [warning setMessage:@"All riders need to sign waiver."];
            [warning setTeam:team];
        }
    }
    
    BOOL success = [[RRDataManager sharedRRDataManager] save];
    if (!success)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Warnings could not be created." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - public methods

- (int)numberOfRides
{
    NSArray *riders = [[RRDataManager sharedRRDataManager] allRiders];
    int numberOfRides = 0;
    
    for (Rider *rider in riders)
    {
        numberOfRides += [rider.numberOfRides intValue];
    }
    
    return numberOfRides;
}

- (int)maximumNumberOfRidesPerRider
{
    NSArray *riders = [[RRDataManager sharedRRDataManager] allRiders];
    int maximumNumberOfRides = 0;
    
    for (Rider *rider in riders)
    {
        maximumNumberOfRides = MAX(maximumNumberOfRides, [rider.numberOfRides intValue]);
    }
    
    return maximumNumberOfRides;
}

- (int)calculatedNumberOfTeams
{
    float numberOfRides = [self numberOfRides];
    float numberOfTeams = numberOfRides / kMaxRidersPerTeam;
    return MAX(ceil(numberOfTeams), [self maximumNumberOfRidesPerRider]);
}

@end
