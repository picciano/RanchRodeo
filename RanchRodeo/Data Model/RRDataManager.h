//
//  RRDataManager.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/22/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"

@class Rider;
@class Team;
@class Warning;

@interface RRDataManager : NSObject

CWL_DECLARE_SINGLETON_FOR_CLASS(RRDataManager);

- (NSArray *)allRiders;
- (Rider *)newRider;

@end
