//
//  RRRiderViewController.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/22/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRRiderViewController.h"

@interface RRRiderViewController ()

@property (weak, nonatomic) IBOutlet UILabel *numberOfRidesLabel;

- (IBAction)numberOfRidesDidUpdate:(id)sender;
- (IBAction)saveRider:(id)sender;

@end

@implementation RRRiderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setTitle:@"Rider"];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.numberOfRidesLabel setText:[RRUtilities stringFromNumber:[self.rider numberOfRides]]];
}

- (IBAction)numberOfRidesDidUpdate:(id)sender
{
    UIStepper *numberOfRidesStepper = (UIStepper *)sender;
    [self.numberOfRidesLabel setText:[RRUtilities stringFromNumber:[NSNumber numberWithDouble:[numberOfRidesStepper value]]]];
}

- (IBAction)saveRider:(id)sender
{
    [self.rider setFirstName:@"Anthony"];
    [self.rider setLastName:@"Picciano"];
    [self.rider setNumberOfRides:[RRUtilities numberFromString:self.numberOfRidesLabel.text]];
//    [self.rider setIsChild:[NSNumber numberWithBool:NO]];
//    [self.rider setIsParent:[NSNumber numberWithBool:NO]];
//    [self.rider setIsRoper:[NSNumber numberWithBool:NO]];
//    [self.rider setIsNewRider:[NSNumber numberWithBool:NO]];
//    [self.rider setIsWaiverSigned:[NSNumber numberWithBool:YES]];
    
    BOOL success = [[RRDataManager sharedRRDataManager] save];
    if (success) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
