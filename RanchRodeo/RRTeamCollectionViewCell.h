//
//  RRTeamCollectionViewCell.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 6/17/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RRTeamCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *teamNumberLabel;
@property (nonatomic, weak) IBOutlet UIButton *warningButton;
@property (nonatomic, weak) IBOutlet UIButton *editButton;

- (UILabel *)riderNameLabelByNumber:(int)index;

@end
