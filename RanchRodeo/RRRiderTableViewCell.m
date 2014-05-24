//
//  RRRiderTableViewCell.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/23/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRRiderTableViewCell.h"

@interface RRRiderTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfRidesLabel;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;

@end

@implementation RRRiderTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setRider:(Rider *)rider
{
    if (_rider == rider)
    {
        return;
    }
    
    _rider = rider;
    
    [self updateInterface];
}

- (void)updateInterface
{
    [self.nameLabel setText:[NSString stringWithFormat:@"%@ %@", self.rider.firstName, self.rider.lastName]];
    [self.numberOfRidesLabel setText:[RRUtilities stringFromNumber:[self.rider numberOfRides]]];
    [self.categoryLabel setText:[self.rider category]];
}

@end
