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
    
    // retrieve riders
    NSArray *riders = [RRDataManager allRiders];
    
    // create teams
    int numberOfTeams = [RRUtilities numberOfTeams:riders];
    for (int i=0; i < numberOfTeams; i++)
    {
        Team *team = [RRDataManager createTeam];
        [team setNumber:[NSNumber numberWithInt:i+1]];
    }
    
    // retrieve teams
    NSArray *teams = [RRDataManager allTeams];
    
    NSMutableArray *warnings = [NSMutableArray arrayWithCapacity:0];
    NSLog(@"number of teams: %i", [teams count]);
    
    BOOL success = [RRDataManager save];
    if (!success)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Erri=or" message:@"Teams could not be created." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
    }
    
    return warnings;
}

@end
