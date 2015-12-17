//
//  Action.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 12/16/15.
//  Copyright © 2015 Anthony Picciano. All rights reserved.
//

#import "Action.h"

@implementation Action

- (NSString *)description {
    NSMutableString *result = [NSMutableString string];
    
    [result appendString:self.type == ActionTypeMove?@"Move rider to ":@"Swap rider with "];
    
    if (self.otherRider) {
        [result appendString:self.otherRider.fullName];
        [result appendString:@" in "];
    }
    
    [result appendString:@"team "];
    [result appendString:self.toTeam.number.description];
    
    return result;
}

@end
