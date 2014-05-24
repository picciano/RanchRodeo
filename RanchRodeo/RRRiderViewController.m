//
//  RRRiderViewController.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/22/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRRiderViewController.h"

@interface RRRiderViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRidesLabel;
@property (weak, nonatomic) IBOutlet UISwitch *isParentSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *isChildSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *isRoperSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *isNewRiderSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *isWaiverSignedSwitch;

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
    
    [self updateDisplayFromDataObject];
}

- (IBAction)numberOfRidesDidUpdate:(id)sender
{
    UIStepper *numberOfRidesStepper = (UIStepper *)sender;
    self.numberOfRidesLabel.text = [RRUtilities stringFromDouble:numberOfRidesStepper.value];
}

- (void)updateDisplayFromDataObject
{
    self.firstNameField.text = self.rider.firstName;
    self.lastNameField.text = self.rider.lastName;
    self.numberOfRidesLabel.text = [RRUtilities stringFromNumber:self.rider.numberOfRides];
    self.isChildSwitch.on = [self.rider.isChild boolValue];
    self.isParentSwitch.on = [self.rider.isParent boolValue];
    self.isRoperSwitch.on = [self.rider.isRoper boolValue];
    self.isNewRiderSwitch.on = [self.rider.isNewRider boolValue];
    self.isWaiverSignedSwitch.on = [self.rider.isWaiverSigned boolValue];
}

- (void)updateDataObjectFromDisplay
{
    self.rider.firstName = self.firstNameField.text;
    self.rider.lastName = self.lastNameField.text;
    self.rider.numberOfRides = [RRUtilities numberFromString:self.numberOfRidesLabel.text];
    self.rider.isChild = [NSNumber numberWithBool:self.isChildSwitch.on];
    self.rider.isParent = [NSNumber numberWithBool:self.isParentSwitch.on];
    self.rider.isRoper = [NSNumber numberWithBool:self.isRoperSwitch.on];
    self.rider.isNewRider = [NSNumber numberWithBool:self.isNewRiderSwitch.on];
    self.rider.isWaiverSigned = [NSNumber numberWithBool:self.isWaiverSignedSwitch.on];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.firstNameField.text.length == 0 || self.lastNameField.text.length == 0)
    {
        [RRDataManager rollback];
    }
    else
    {
        [self updateDataObjectFromDisplay];
        [RRDataManager save];
    }
}

- (IBAction)saveRider:(id)sender
{
    if (self.firstNameField.text.length == 0 || self.lastNameField.text.length == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter Missing Data" message:@"Please enter a first and last name." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [self updateDataObjectFromDisplay];
    
    if ([RRDataManager save])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end