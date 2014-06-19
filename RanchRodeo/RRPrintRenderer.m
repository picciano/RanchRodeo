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
        self.headerHeight = 36.0f;
        self.footerHeight = 0.0f;
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
    CGRect original = self.collectionView.frame;
    CGRect adjusted = original;
    
    CGSize contentSize = self.collectionView.contentSize;
    adjusted.size = contentSize;
    self.collectionView.frame = adjusted;
    
    CGRect printRect = CGRectInset(contentRect, 18.0f, 18.0f);
    
    float printAreaRatio = CGRectGetWidth(printRect) / CGRectGetHeight(printRect);
    float adjustedRatio = CGRectGetWidth(adjusted) / CGRectGetHeight(adjusted);
    
    if (printAreaRatio > adjustedRatio)
    {
        // adjust width of print area
        float newWidth = (CGRectGetHeight(printRect) / CGRectGetHeight(adjusted)) * CGRectGetWidth(adjusted);
        float shiftAmount = (printRect.size.width - newWidth) / 2.0f;
        printRect.size.width = newWidth;
        
        // center it horizontally
        printRect.origin.x += shiftAmount;
    }
    else
    {
        // adjust height of print area
        float newHeight = (CGRectGetWidth(printRect) / CGRectGetWidth(adjusted)) * CGRectGetHeight(adjusted);
        float shiftAmount = (printRect.size.height - newHeight) / 2.0f;
        printRect.size.height = newHeight;
        
        // center it vertically
        printRect.origin.y += shiftAmount;
    }
    
    [self.collectionView drawViewHierarchyInRect:printRect afterScreenUpdates:YES];
    
    self.collectionView.frame = original;
}

@end
