//
//  RRRiderViewController.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/22/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRRiderViewController.h"
#import "UIControl+NextControl.h"

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
@property (weak, nonatomic) IBOutlet UISwitch *isMemberOfTeamSwitch;

@property (weak, nonatomic) IBOutlet UIView *teamNumberView;
@property (weak, nonatomic) IBOutlet UIStepper *numberOfRidesStepper;
@property (weak, nonatomic) IBOutlet UIStepper *teamNumberStepper;
@property (weak, nonatomic) IBOutlet UILabel *teamNumberLabel;

@property (strong, nonatomic) NSArray *parents;

- (IBAction)numberOfRidesDidUpdate:(id)sender;
- (IBAction)teamNumberDidUpdate:(id)sender;
- (IBAction)saveRider:(id)sender;
- (IBAction)isChildSwitchChanged:(id)sender;
- (IBAction)isParentSwitchChanged:(id)sender;
- (IBAction)isMemberOfTeamSwitchChanged:(id)sender;

@end

@implementation RRRiderViewController

NSString * const kParentCell = @"parentCell";

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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kParentCell];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateDisplayFromDataObject];
    [self loadData];
}

- (void)loadData
{
    [self setParents:[[RRDataManager sharedRRDataManager] allParentRiders]];
    [self.tableView reloadData];
    [self updateDisplay];
}

- (void)updateDisplay
{
    if ([self.firstNameField.text isEqualToString:@""])
    {
        [self.firstNameField becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField transferFirstReponderToNextControl];
    return NO;
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

- (IBAction)isMemberOfTeamSwitchChanged:(id)sender {
    self.teamNumberView.hidden = ![self.isMemberOfTeamSwitch isOn];
}

- (IBAction)numberOfRidesDidUpdate:(id)sender
{
    UIStepper *numberOfRidesStepper = (UIStepper *)sender;
    self.numberOfRidesLabel.text = [RRUtilities stringFromDouble:numberOfRidesStepper.value];
}

- (IBAction)teamNumberDidUpdate:(id)sender {
    UIStepper *teamNumberStepper = (UIStepper *)sender;
    self.teamNumberLabel.text = [RRUtilities stringFromDouble:teamNumberStepper.value];
}

- (void)updateDisplayFromDataObject
{
    self.firstNameField.text = self.rider.firstName;
    self.lastNameField.text = self.rider.lastName;
    self.numberOfRidesLabel.text = [RRUtilities stringFromNumber:self.rider.numberOfRides];
    self.numberOfRidesStepper.value = [self.rider.numberOfRides doubleValue];
    self.teamNumberLabel.text = [RRUtilities stringFromNumber:self.rider.teamNumber];
    self.teamNumberStepper.value = [self.rider.teamNumber doubleValue];
    self.isChildSwitch.on = [self.rider.isChild boolValue];
    self.isParentSwitch.on = [self.rider.isParent boolValue];
    self.isRoperSwitch.on = [self.rider.isRoper boolValue];
    self.isNewRiderSwitch.on = [self.rider.isNewRider boolValue];
    self.isWaiverSignedSwitch.on = [self.rider.isWaiverSigned boolValue];
    self.isMemberOfTeamSwitch.on = [self.rider.isMemberOfTeam boolValue];
    
    // only show parent table if rider is a child
    self.tableView.hidden = ![self.rider.isChild boolValue];
    
    // only show team number view is rider is a member of a team
    self.teamNumberView.hidden = ![self.rider.isMemberOfTeam boolValue];
}

- (void)updateDataObjectFromDisplay
{
    self.rider.firstName = self.firstNameField.text;
    self.rider.lastName = self.lastNameField.text;
    self.rider.numberOfRides = [RRUtilities numberFromString:self.numberOfRidesLabel.text];
    self.rider.teamNumber = [RRUtilities numberFromString:self.teamNumberLabel.text];
    self.rider.isChild = [NSNumber numberWithBool:self.isChildSwitch.on];
    self.rider.isParent = [NSNumber numberWithBool:self.isParentSwitch.on];
    self.rider.isRoper = [NSNumber numberWithBool:self.isRoperSwitch.on];
    self.rider.isNewRider = [NSNumber numberWithBool:self.isNewRiderSwitch.on];
    self.rider.isWaiverSigned = [NSNumber numberWithBool:self.isWaiverSignedSwitch.on];
    self.rider.isMemberOfTeam = [NSNumber numberWithBool:self.isMemberOfTeamSwitch.on];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.firstNameField.text.length == 0 || self.lastNameField.text.length == 0)
    {
        [[RRDataManager sharedRRDataManager] rollback];
    }
    else
    {
        [self updateDataObjectFromDisplay];
        [[RRDataManager sharedRRDataManager] save];
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
    
    if ([[RRDataManager sharedRRDataManager] save])
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kParentCell forIndexPath:indexPath];
    
    Rider *parent = (Rider *)self.parents[indexPath.row];
    [cell.textLabel setText:[parent fullName]];
    [cell setAccessoryType:[self.rider.parents containsObject:parent]?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone];
    
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
    Rider *parent = (Rider *)self.parents[indexPath.row];
    
    if ([self.rider.parents containsObject:parent])
    {
        [self.rider removeParentsObject:parent];
    }
    else
    {
        [self.rider addParentsObject:parent];
    }
    
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Select Parent(s)";
}

@end
