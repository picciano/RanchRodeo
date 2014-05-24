//
//  Rider+Category.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/23/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "Rider+Category.h"

@implementation Rider (Category)

NSString * const kRiderCategoryChild = @"K";
NSString * const kRiderCategoryParent = @"P";
NSString * const kRiderCategoryRoper = @"R";
NSString * const kRiderCategoryNewRider = @"N";
NSString * const kRiderCategoryGeneral = @"G";

- (NSString *)category
{
    NSMutableString *category = [[NSMutableString alloc] init];
    
    if ([[self isChild] boolValue]) {
        [category appendString:kRiderCategoryChild];
    }
    
    if ([[self isParent] boolValue]) {
        [category appendString:kRiderCategoryParent];
    }

    if ([[self isRoper] boolValue]) {
        [category appendString:kRiderCategoryRoper];
    }
    
    if ([[self isNewRider] boolValue]) {
        [category appendString:kRiderCategoryNewRider];
    }
    
    if ([category length] == 0)
    {
        [category appendString:kRiderCategoryGeneral];
    }
    
    return category;
}

@end
