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
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kRRDataManagerEntityTypeRider];
    NSArray *objects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return objects;
}

- (Rider *)newRider
{
    Rider *object = [NSEntityDescription insertNewObjectForEntityForName:kRRDataManagerEntityTypeRider inManagedObjectContext:[self managedObjectContext]];
    return object;
}

- (BOOL)save
{
    NSError *error = nil;
    [[self managedObjectContext] save:&error];
    
    return (error == nil);
}

@end
