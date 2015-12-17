//
//  RRRegistrationViewController.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/22/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRRegistrationViewController.h"
#import "RRRiderViewController.h"
#import "RRRosterViewController.h"
#import "RRRiderTableViewCell.h"
#import "RRTeamGenerator.h"

@interface RRRegistrationViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRidersLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRidesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfTeamsLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ridersPerTeamControl;

@property (strong, nonatomic) NSArray *allRiders;
@property (strong, nonatomic) NSArray *enabledRiders;

- (IBAction)createRider:(id)sender;
- (IBAction)viewRoster:(id)sender;

@end

@implementation RRRegistrationViewController

NSString * const kRRRegistrationEraseChallengeText = @"erase";
NSString * const kRRRegistrationRiderCell = @"riderCell";

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setTitle:@"Registration"];
        
        UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(resetData)];
        [self.navigationItem setLeftBarButtonItem:resetItem];
        
        UIBarButtonItem *newItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createRider:)];
        [self.navigationItem setRightBarButtonItem:newItem];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView
     registerNib:[UINib nibWithNibName:@"RRRiderTableViewCell"
                                bundle:[NSBundle mainBundle]]
     forCellReuseIdentifier:kRRRegistrationRiderCell];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadData
{
    self.allRiders = [[RRDataManager sharedRRDataManager] allRiders];
    self.enabledRiders = [[RRDataManager sharedRRDataManager] allEnabledRiders];
    [self.tableView reloadData];
    [self updateDisplay];
}

- (void)updateDisplay
{
    self.numberOfRidersLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.enabledRiders.count];
    self.numberOfRidesLabel.text = [NSString stringWithFormat:@"%i", [[RRTeamGenerator sharedRRTeamGenerator] numberOfRides]];
    self.numberOfTeamsLabel.text = [NSString stringWithFormat:@"%i", [[RRTeamGenerator sharedRRTeamGenerator] calculatedNumberOfTeams]];
    
    NSInteger ridersPerTeam = [[NSUserDefaults standardUserDefaults] integerForKey:@"ridersPerTeam"];
    
    if (ridersPerTeam != 3 && ridersPerTeam != 4) {
        ridersPerTeam = 4;
        [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"ridersPerTeam"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    self.ridersPerTeamControl.selectedSegmentIndex = ridersPerTeam - 3;
}

- (IBAction)createRider:(id)sender
{
    RRRiderViewController *viewController = [[RRRiderViewController alloc] initWithNibName:nil bundle:nil];
    [viewController setRider:[[RRDataManager sharedRRDataManager] createRider]];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)viewRoster:(id)sender
{
    if ([[RRDataManager sharedRRDataManager] needsTeamGeneration] ||
        [[[RRDataManager sharedRRDataManager] allTeams] count] < [[RRTeamGenerator sharedRRTeamGenerator] calculatedNumberOfTeams])
    {
        [[RRTeamGenerator sharedRRTeamGenerator] generateTeams];
    }
    
    RRRosterViewController *viewController = [[RRRosterViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)ridersPerTeamChanged:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
    [[NSUserDefaults standardUserDefaults] setInteger:control.selectedSegmentIndex + 3 forKey:@"ridersPerTeam"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[RRDataManager sharedRRDataManager] setNeedsTeamGeneration:YES];
    [self updateDisplay];
}

#pragma mark - Reset Data

- (void)resetData
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Are you certain that you want to erase all of the registration data? This action cannot be undone.\n\nEnter \"%@\" to confirm this action.", kRRRegistrationEraseChallengeText] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Erase all", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        return;
    }
    
    if (![[alertView textFieldAtIndex:0].text isEqualToString:kRRRegistrationEraseChallengeText])
    {
        UIAlertView *notErasedAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation Incorrect" message:@"The confirmation code was not entered correctly. The registration data was not erased." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [notErasedAlertView show];
        
        return;
    }
    
    [[RRDataManager sharedRRDataManager] reset];
    [self loadData];
    
    UIAlertView *erasedAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"The registration data has been erased." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [erasedAlertView show];
}

- (void)enabledSwitchAction:(id)sender {
    UISwitch *enabledSwitch = (UISwitch *)sender;
    NSInteger index = enabledSwitch.tag;
    Rider *rider = self.allRiders[index];
    rider.isEnabled = [NSNumber numberWithBool:enabledSwitch.on];
    [[RRDataManager sharedRRDataManager] save];
    
    [self loadData];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allRiders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RRRiderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRRRegistrationRiderCell forIndexPath:indexPath];
    Rider *rider = self.allRiders[indexPath.row];
    [cell setRider:rider];
    
    UISwitch *enabledSwitch = [[UISwitch alloc] init];
    enabledSwitch.on = rider.isEnabled.boolValue;
    enabledSwitch.tag = indexPath.row;
    [enabledSwitch addTarget:self action:@selector(enabledSwitchAction:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = enabledSwitch;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    [(RRRiderTableViewCell *)cell updateInterface];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RRRiderViewController *viewController = [[RRRiderViewController alloc] initWithNibName:nil bundle:nil];
    [viewController setRider:self.allRiders[indexPath.row]];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[RRDataManager sharedRRDataManager] destroyObject:self.allRiders[indexPath.row]];
        [self loadData];
    }
}

@end
