//
//  RRDataManager.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/22/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRDataManager.h"
#import "RRAppDelegate.h"

@interface RRDataManager ()

- (NSManagedObjectContext *)managedObjectContext;
- (void)deleteEntitiesOfType:(NSString *)type;

@end

@implementation RRDataManager

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(RRDataManager);

NSString * const kRRDataManagerEntityTypeRider = @"Rider";
NSString * const kRRDataManagerEntityTypeTeam = @"Team";
NSString * const kRRDataManagerEntityTypeWarning = @"Warning";

- (NSManagedObjectContext *)managedObjectContext
{
    return [(RRAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (NSArray *)allRiders
{
    return [self allRidersUsingPredicate:nil];
}

- (NSArray *)allEnabledRiders
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isEnabled == YES"];
    return [self allRidersUsingPredicate:predicate];
}

- (NSArray *)allTeams
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kRRDataManagerEntityTypeTeam];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES]]];
    NSArray *objects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return objects;
}

- (Team *)teamWithNumber:(int)teamNumber
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kRRDataManagerEntityTypeTeam];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number == %i", teamNumber];
    [fetchRequest setPredicate:predicate];
    NSArray *objects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return objects.firstObject;
}

- (NSArray *)teamsWithMissingRiders
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:3];
    for (Team *team in self.allTeams)
    {
        if (team.riders.count < 4)
        {
            [objects addObject:team];
        }
    }
    return objects;
}

- (NSArray *)allWarnings
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kRRDataManagerEntityTypeWarning];
    NSArray *objects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return objects;
}

- (NSArray *)allParentRiders
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isParent == YES AND isEnabled == YES"];
    return [self allRidersUsingPredicate:predicate];
}

- (NSArray *)allChildRiders
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isChild == YES AND isEnabled == YES"];
    return [self allRidersUsingPredicate:predicate];
}

- (NSArray *)allRopers
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRoper == YES AND isEnabled == YES"];
    return [self allRidersUsingPredicate:predicate];
}

- (NSArray *)allNewRiders
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isNewRider == YES AND isEnabled == YES"];
    return [self allRidersUsingPredicate:predicate];
}

- (NSArray *)allRidersWithExtraRides
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"numberOfRides > 2 AND isEnabled == YES"];
    return [self allRidersUsingPredicate:predicate];
}

- (NSArray *)allRidersWithMemberOfTeam
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isMemberOfTeam == YES AND isEnabled == YES"];
    return [self allRidersUsingPredicate:predicate];
}

- (NSArray *)allRidersUsingPredicate:(NSPredicate *)predicate
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kRRDataManagerEntityTypeRider];
    if (predicate)
    {
        [fetchRequest setPredicate:predicate];
    }
    NSArray *objects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return objects;
}

- (Rider *)createRider
{
    Rider *object = [NSEntityDescription insertNewObjectForEntityForName:kRRDataManagerEntityTypeRider inManagedObjectContext:[self managedObjectContext]];
    return object;
}

- (Team *)createTeam
{
    Team *object = [NSEntityDescription insertNewObjectForEntityForName:kRRDataManagerEntityTypeTeam inManagedObjectContext:[self managedObjectContext]];
    return object;
}

- (Warning *)createWarning;
{
    Warning *object = [NSEntityDescription insertNewObjectForEntityForName:kRRDataManagerEntityTypeWarning inManagedObjectContext:[self managedObjectContext]];
    return object;
}

- (BOOL)destroyObject:(NSManagedObject *)object
{
    [[self managedObjectContext] deleteObject:object];
    NSError *saveError = nil;
    [[self managedObjectContext] save:&saveError];
    
    return (saveError == nil);
}

- (void)moveRider:(Rider *)rider fromTeam:(Team *)fromTeam toTeam:(Team *)toTeam
{
    [fromTeam removeRidersObject:rider];
    [toTeam addRidersObject:rider];
    
    [self saveAndRegenerateIfNeeded:NO];
}

- (void)rollback
{
    [[self managedObjectContext] rollback];
}

- (BOOL)save
{
    return [self saveAndRegenerateIfNeeded:YES];
}

- (BOOL)saveAndRegenerateIfNeeded:(BOOL)regenerateIfNeeded
{
    if (regenerateIfNeeded && [[self managedObjectContext] hasChanges])
    {
        [self setNeedsTeamGeneration:YES];
    }
    
    NSError *saveError = nil;
    [[self managedObjectContext] save:&saveError];
    
    if (saveError) {
        NSLog(@"Error saving: %@", saveError.localizedDescription);
    }
    
    return (saveError == nil);
}

- (void)reset
{
    [self deleteTeams];
    [self deleteEntitiesOfType:kRRDataManagerEntityTypeRider];
}

- (void)deleteTeams
{
    [self deleteEntitiesOfType:kRRDataManagerEntityTypeWarning];
    [self deleteEntitiesOfType:kRRDataManagerEntityTypeTeam];
}

- (void)deleteEntitiesOfType:(NSString *)type
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:type inManagedObjectContext:[self managedObjectContext]]];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *objects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *object in objects)
    {
        [[self managedObjectContext] deleteObject:object];
    }
    NSError *saveError = nil;
    [[self managedObjectContext] save:&saveError];
}

@end
