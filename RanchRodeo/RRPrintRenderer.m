//
//  RRPrintRenderer.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 6/17/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRPrintRenderer.h"

@implementation RRPrintRenderer

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.headerHeight = 100.0f;
        self.footerHeight = 100.0f;
    }
    
    return self;
}

- (void)drawHeaderForPageAtIndex:(NSInteger)pageIndex  inRect:(CGRect)headerRect
{
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12.0];
    NSDictionary *attrsDictionary =
    [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    CGSize titleSize = [self.jobTitle sizeWithAttributes:attrsDictionary];
    CGFloat drawX = CGRectGetMaxX(headerRect)/2 - titleSize.width/2;
    CGFloat drawY = CGRectGetMaxY(headerRect) - titleSize.height;
    CGPoint drawPoint = CGPointMake(drawX, drawY);
    
    [self.jobTitle drawAtPoint:drawPoint withAttributes:attrsDictionary];
}

- (void)drawContentForPageAtIndex:(NSInteger)pageIndex inRect:(CGRect)contentRect
{
    [self.collectionView drawViewHierarchyInRect:contentRect afterScreenUpdates:NO];
}

@end
