//
//  Team.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/22/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Team : NSManagedObject

@property (nonatomic, retain) NSSet *riders;
@property (nonatomic, retain) NSSet *warnings;
@property (nonatomic, retain) NSNumber * number;
@end

@interface Team (CoreDataGeneratedAccessors)

- (void)addRidersObject:(NSManagedObject *)value;
- (void)removeRidersObject:(NSManagedObject *)value;
- (void)addRiders:(NSSet *)values;
- (void)removeRiders:(NSSet *)values;

- (void)addWarningsObject:(NSManagedObject *)value;
- (void)removeWarningsObject:(NSManagedObject *)value;
- (void)addWarnings:(NSSet *)values;
- (void)removeWarnings:(NSSet *)values;

@end
