//
//  RRTeamCollectionViewCell.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 6/17/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRTeamCollectionPrintViewCell.h"

@interface RRTeamCollectionPrintViewCell()

@property (nonatomic, weak) IBOutlet UILabel *rider1NameLabel;
@property (nonatomic, weak) IBOutlet UILabel *rider2NameLabel;
@property (nonatomic, weak) IBOutlet UILabel *rider3NameLabel;
@property (nonatomic, weak) IBOutlet UILabel *rider4NameLabel;

@end

@implementation RRTeamCollectionPrintViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"RRTeamCollectionPrintViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1)
        {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]])
        {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
    }
    
    return self;
}

- (UILabel *)riderNameLabelByNumber:(int)index
{
    UILabel *riderNameLabel = nil;
    
    switch (index)
    {
        case 0:
            riderNameLabel = self.rider1NameLabel;
            break;
            
        case 1:
            riderNameLabel = self.rider2NameLabel;
            break;
            
        case 2:
            riderNameLabel = self.rider3NameLabel;
            break;
            
        case 3:
            riderNameLabel = self.rider4NameLabel;
            break;
            
        default:
            break;
    }
    
    return riderNameLabel;
}

@end
