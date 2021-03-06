//
//  Rider+Category.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/23/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "Rider.h"

@interface Rider (Category)

- (NSString *)category;
- (NSString *)fullName;
- (BOOL)hasTeamWithNumberWithin:(int)numberOfRides ofTeamNumber:(int)teamNumber;
- (BOOL)isAlreadyOnATeamWithTheMembersOfTeam:(Team *)team;
- (BOOL)hasRequestedExtraRides;

@end
