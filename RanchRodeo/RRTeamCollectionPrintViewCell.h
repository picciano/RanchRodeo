//
//  RRTeamCollectionPrintViewCell.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 6/17/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RRTeamCollectionPrintViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *teamNumberLabel;

- (UILabel *)riderNameLabelByNumber:(int)index;

@end
