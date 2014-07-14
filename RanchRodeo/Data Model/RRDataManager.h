//
//  RRDataManager.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/22/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"
#import "Rider.h"
#import "Team.h"
#import "Warning.h"

@interface RRDataManager : NSObject

CWL_DECLARE_SINGLETON_FOR_CLASS(RRDataManager);

@property (nonatomic) BOOL needsTeamGeneration;

- (void)rollback;
- (BOOL)save;
- (void)reset;
- (void)deleteTeams;
- (NSArray *)allRiders;
- (NSArray *)allTeams;
- (NSArray *)allWarnings;
- (NSArray *)allParentRiders;
- (NSArray *)allChildRiders;
- (NSArray *)allRopers;
- (NSArray *)allNewRiders;
- (NSArray *)allRidersWithExtraRides;
- (Rider *)createRider;
- (Team *)createTeam;
- (Warning *)createWarning;
- (BOOL)destroyObject:(NSManagedObject *)object;

@end
