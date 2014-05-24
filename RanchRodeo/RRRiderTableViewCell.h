//
//  RRRiderTableViewCell.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/23/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RRRiderTableViewCell : UITableViewCell

@property (nonatomic, weak) Rider *rider;

- (void)updateInterface;

@end
