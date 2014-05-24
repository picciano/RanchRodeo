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
@property (nonatomic, weak) IBOutlet UIImageView *waiverSignedImageView;

@end

@implementation RRRiderTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)updateInterface
{
    [self.nameLabel setText:[NSString stringWithFormat:@"%@ %@", self.rider.firstName, self.rider.lastName]];
    [self.numberOfRidesLabel setText:[RRUtilities stringFromNumber:[self.rider numberOfRides]]];
    [self.categoryLabel setText:[self.rider category]];
    [self.waiverSignedImageView setHighlighted:[self.rider.isWaiverSigned boolValue]];
}

@end
