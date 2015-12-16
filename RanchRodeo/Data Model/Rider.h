//
//  Rider.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/23/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Rider, Team;

@interface Rider : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * isChild;
@property (nonatomic, retain) NSNumber * isNewRider;
@property (nonatomic, retain) NSNumber * isRoper;
@property (nonatomic, retain) NSNumber * isWaiverSigned;
@property (nonatomic, retain) NSNumber * isMemberOfTeam;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * numberOfRides;
@property (nonatomic, retain) NSNumber * teamNumber;
//@property (nonatomic, retain) NSNumber * isEnabled;
@property (nonatomic, retain) NSNumber * isParent;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) NSSet *parents;
@property (nonatomic, retain) NSSet *teams;
@end

@interface Rider (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(Rider *)value;
- (void)removeChildrenObject:(Rider *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

- (void)addParentsObject:(Rider *)value;
- (void)removeParentsObject:(Rider *)value;
- (void)addParents:(NSSet *)values;
- (void)removeParents:(NSSet *)values;

- (void)addTeamsObject:(Team *)value;
- (void)removeTeamsObject:(Team *)value;
- (void)addTeams:(NSSet *)values;
- (void)removeTeams:(NSSet *)values;

@end
