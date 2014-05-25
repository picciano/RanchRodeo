//
//  RRRiderViewController.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/22/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRRiderViewController.h"

@interface RRRiderViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRidesLabel;
@property (weak, nonatomic) IBOutlet UISwitch *isParentSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *isChildSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *isRoperSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *isNewRiderSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *isWaiverSignedSwitch;
@property (weak, nonatomic) IBOutlet UIStepper *numberOfRidesStepper;

@property (strong, nonatomic) NSArray *parents;

- (IBAction)numberOfRidesDidUpdate:(id)sender;
- (IBAction)saveRider:(id)sender;
- (IBAction)isChildSwitchChanged:(id)sender;
- (IBAction)isParentSwitchChanged:(id)sender;

@end

@implementation RRRiderViewController

NSString * const kRParentCell = @"parentCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setTitle:@"Rider"];
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kRParentCell];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateDisplayFromDataObject];
    [self loadData];
}

- (void)loadData
{
    [self setParents:[RRDataManager allParentRiders]];
    [self.tableView reloadData];
    [self updateDisplay];
}

- (void)updateDisplay
{
    
}

- (IBAction)isChildSwitchChanged:(id)sender
{
    self.tableView.hidden = ![self.isChildSwitch isOn];
    
    if ([self.isChildSwitch isOn])
    {
        self.isParentSwitch.on = NO;
        [self isParentSwitchChanged:sender];
    }
}

- (IBAction)isParentSwitchChanged:(id)sender
{
    if ([self.isParentSwitch isOn])
    {
        self.isChildSwitch.on = NO;
        [self isChildSwitchChanged:sender];
    }
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
    self.numberOfRidesStepper.value = [self.rider.numberOfRides doubleValue];
    self.isChildSwitch.on = [self.rider.isChild boolValue];
    self.isParentSwitch.on = [self.rider.isParent boolValue];
    self.isRoperSwitch.on = [self.rider.isRoper boolValue];
    self.isNewRiderSwitch.on = [self.rider.isNewRider boolValue];
    self.isWaiverSignedSwitch.on = [self.rider.isWaiverSigned boolValue];
    
    self.tableView.hidden = ![self.rider.isChild boolValue];
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

#pragma mark - UITableViewDataSource and UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.parents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRParentCell forIndexPath:indexPath];
    Rider *parent = (Rider *)self.parents[indexPath.row];
    [cell.textLabel setText:[parent fullName]];
    
    if ([self.rider.parents containsObject:parent])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    ((UITableViewHeaderFooterView *)view).backgroundView.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Select Parent";
}

@end
