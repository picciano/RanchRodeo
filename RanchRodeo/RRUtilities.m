//
//  RRUtilities.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/23/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRUtilities.h"

@implementation RRUtilities

static NSNumberFormatter *f;

+ (NSString *)stringFromNumber:(NSNumber *)number
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterNoStyle];
        [f setMaximumFractionDigits:0];
    });
    
    return [f stringFromNumber:number];
}

+ (NSNumber *)numberFromString:(NSString *)string
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterNoStyle];
        [f setMaximumFractionDigits:0];
    });
    
    return [f numberFromString:string];
}

@end
