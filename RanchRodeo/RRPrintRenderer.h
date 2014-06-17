//
//  RRPrintRenderer.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 6/17/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RRPrintRenderer : UIPrintPageRenderer

@property (nonatomic, strong) NSString *jobTitle;
@property (nonatomic, strong) UICollectionView *collectionView;

@end
