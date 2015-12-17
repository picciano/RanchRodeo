//
//  Action.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 12/16/15.
//  Copyright © 2015 Anthony Picciano. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ActionTypeMove,
    ActionTypeSwap
} ActionType;

@interface Action : NSObject

@property (nonatomic, strong) Rider *riderToMove;
@property (nonatomic, strong) Rider *otherRider;
@property (nonatomic, strong) Team *fromTeam;
@property (nonatomic, strong) Team *toTeam;
@property (nonatomic) ActionType type;

@end
