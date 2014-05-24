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

+ (void)rollback;
+ (BOOL)save;
+ (void)reset;
+ (NSArray *)allRiders;
+ (Rider *)createRider;
+ (BOOL)destroyObject:(NSManagedObject *)object;

@end
