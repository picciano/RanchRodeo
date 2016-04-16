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

int const kMinimumWaitBetweenRides = 2;
int const kPreferredWaitBetweenRides = 3;

- (NSInteger)ridersPerTeam {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"ridersPerTeam"];
}

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
    
    // add self-determined teams
    [self processSelfDeterminedTeam:[[RRDataManager sharedRRDataManager] allRidersWithMemberOfTeam]];
    
    // add children and their parents to teams
    [self processRiders:[[RRDataManager sharedRRDataManager] allChildRiders]];
    
    // add ropers to teams
    [self processRiders:[[RRDataManager sharedRRDataManager] allRopers]];
    
    // add new riders to teams
    [self processRiders:[[RRDataManager sharedRRDataManager] allNewRiders]];
    
    // add riders with extra rides to teams
    [self processRiders:[[RRDataManager sharedRRDataManager] allRidersWithExtraRides]];
    
    // add everyone else to teams
    [self processRiders:[[RRDataManager sharedRRDataManager] allEnabledRiders]];
    
    // check for team warnings
    [self determineWarnings];
    
    [[RRDataManager sharedRRDataManager] setNeedsTeamGeneration:NO];
}

- (void)processSelfDeterminedTeam:(NSArray *)riders
{
    NSArray *teams = [[RRDataManager sharedRRDataManager] allTeams];
    
    for (Rider *rider in riders)
    {
        if ([rider.teamNumber intValue] < teams.count)
        {
            Team *team = teams[[rider.teamNumber intValue]];
            [team addRidersObject:rider];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Forming Teams" message:@"A rider has specified a team number that is not available. Choose a lower team number." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alertView show];
        }
    }
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
    
    // mandatory rules
    for (Team *team in teams)
    {
        if (team.riders.count >= [self ridersPerTeam])
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
        if ([rider isAlreadyOnATeamWithTheMembersOfTeam:team]) {
            continue;
        }
        
        if ([rider hasTeamWithNumberWithin:kMinimumWaitBetweenRides ofTeamNumber:team.number.intValue])
        {
            continue;
        }
        
        if ([[rider isChild] boolValue] && team.hasChildRider)
        {
            continue;
        }
        
        [preferredTeams addObject:team];
    }
    
    // optional rules
    for (Team *team in preferredTeams)
    {
        if ([[rider isRoper] boolValue] && team.hasRoper)
        {
            continue;
        }
        
        if ([[rider isNewRider] boolValue] && team.hasNewRider)
        {
            continue;
        }
        
        if ([rider hasTeamWithNumberWithin:kPreferredWaitBetweenRides ofTeamNumber:team.number.intValue])
        {
            continue;
        }
        
        [bestMatchTeams addObject:team];
    }
    
    // teams meets rules, return first result from preferred teams
    if (bestMatchTeams.count > 0)
    {
        Team *result = [self randomTeamFromArray:bestMatchTeams];
        NSLog(@"Returning BEST match for %@: Team %@", rider.fullName, result.number);
        return result;
    }
    
    // teams fails optional rules, return first result from preferred teams
    if (preferredTeams.count > 0)
    {
        Team *result = [self randomTeamFromArray:preferredTeams];
        NSLog(@"Returning PREFERRED match for %@: Team %@", rider.fullName, result.number);
        return result;
    }
    
    // teams failed preferred rules, return first result from potential teams
    if (potentialTeams.count > 0)
    {
        Team *result = [self randomTeamFromArray:potentialTeams];
        NSLog(@"Returning POTENTIAL match for %@: Team %@", rider.fullName, result.number);
        return result;
    }
    
    NSLog(@"No team found for rider: %@", rider);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Forming Teams" message:@"Not all riders were assigned to a team. Please regenerate team again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
    
    return nil;
}

- (Team *)randomTeamFromArray:(NSArray *)array
{
    // prefer teams with the least number of current riders
    for (int i = 0; i < [[RRTeamGenerator sharedRRTeamGenerator] ridersPerTeam]; i++) {
        NSArray *teams = [self teamsFromArray:array withNumberOfRiders:i];
        if (teams.count > 0) {
            return [teams objectAtIndex:rand()%[teams count]];
        }
    }
    
    return [array objectAtIndex:rand()%[array count]];
}

- (NSArray *)teamsFromArray:(NSArray *)teams withNumberOfRiders:(int)number
{
    NSMutableArray *results = [NSMutableArray array];
    for (Team *team in teams)
    {
        if (team.riders.count == number) {
            [results addObject:team];
        }
    }
    return results;
}

- (void)determineWarnings
{
    [[RRDataManager sharedRRDataManager] deleteWarnings];
    
    NSArray *teams = [[RRDataManager sharedRRDataManager] allTeams];
    
    for (Team *team in teams)
    {
        if (team.riders.count != [self ridersPerTeam])
        {
            Warning *warning = [[RRDataManager sharedRRDataManager] createWarning];
            [warning setMessage:[NSString stringWithFormat:@"Team should have %li riders.\nIt currently has %lu.", (long)[self ridersPerTeam], (unsigned long)team.riders.count]];
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
    NSArray *riders = [[RRDataManager sharedRRDataManager] allEnabledRiders];
    int numberOfRides = 0;
    
    for (Rider *rider in riders)
    {
        numberOfRides += [rider.numberOfRides intValue];
    }
    
    return numberOfRides;
}

- (int)maximumNumberOfRidesPerRider
{
    NSArray *riders = [[RRDataManager sharedRRDataManager] allEnabledRiders];
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
    float numberOfTeams = numberOfRides / [self ridersPerTeam];
    return MAX(ceil(numberOfTeams), [self maximumNumberOfRidesPerRider]);
}

@end
