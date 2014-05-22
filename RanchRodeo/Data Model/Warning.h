//
//  Warning.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/22/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Team;

@interface Warning : NSManagedObject

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) Team *team;

@end
