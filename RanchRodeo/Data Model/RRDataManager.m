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

+ (NSManagedObjectContext *)managedObjectContext;

@end

@implementation RRDataManager

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(RRDataManager);

NSString * const kRRDataManagerEntityTypeRider = @"Rider";
NSString * const kRRDataManagerEntityTypeTeam = @"Team";
NSString * const kRRDataManagerEntityTypeWarning = @"Warning";

+ (NSManagedObjectContext *)managedObjectContext
{
    return [(RRAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

+ (NSArray *)allRiders
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kRRDataManagerEntityTypeRider];
    NSArray *objects = [[RRDataManager managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return objects;
}

+ (Rider *)createRider
{
    Rider *object = [NSEntityDescription insertNewObjectForEntityForName:kRRDataManagerEntityTypeRider inManagedObjectContext:[RRDataManager managedObjectContext]];
    return object;
}

+ (BOOL)destroyObject:(NSManagedObject *)object
{
    [[RRDataManager managedObjectContext] deleteObject:object];
    NSError *saveError = nil;
    [[RRDataManager managedObjectContext] save:&saveError];
    
    return (saveError == nil);
}

+ (void)rollback
{
    [[RRDataManager managedObjectContext] rollback];
}

+ (BOOL)save
{
    NSError *saveError = nil;
    [[RRDataManager managedObjectContext] save:&saveError];
    
    return (saveError == nil);
}

+ (void)reset
{
    [self deleteEntitiesOfType:kRRDataManagerEntityTypeRider];
    [self deleteEntitiesOfType:kRRDataManagerEntityTypeTeam];
    [self deleteEntitiesOfType:kRRDataManagerEntityTypeWarning];
}

+ (void)deleteEntitiesOfType:(NSString *)type
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:type inManagedObjectContext:[RRDataManager managedObjectContext]]];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *objects = [[RRDataManager managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *object in objects)
    {
        [[RRDataManager managedObjectContext] deleteObject:object];
    }
    NSError *saveError = nil;
    [[RRDataManager managedObjectContext] save:&saveError];
}

@end