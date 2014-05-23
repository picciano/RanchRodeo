//
//  RRStringUtilities.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/23/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRStringUtilities : NSObject

+ (NSString *)stringFromNumber:(NSNumber *)number;
+ (NSNumber *)numberFromString:(NSString *)string;

@end
