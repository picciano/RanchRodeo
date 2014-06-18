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

@property (strong, nonatomic) NSArray *riders;

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
    [self setRiders:[RRDataManager allRiders]];
    [self.tableView reloadData];
    [self updateDisplay];
}

- (void)updateDisplay
{
    self.numberOfRidersLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.riders.count];
    self.numberOfRidesLabel.text = [NSString stringWithFormat:@"%i", [RRTeamGenerator numberOfRides]];
    self.numberOfTeamsLabel.text = [NSString stringWithFormat:@"%i", [RRTeamGenerator calculatedNumberOfTeams]];
}

- (IBAction)createRider:(id)sender
{
    RRRiderViewController *viewController = [[RRRiderViewController alloc] initWithNibName:nil bundle:nil];
    [viewController setRider:[RRDataManager createRider]];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)viewRoster:(id)sender
{
    // always generate teams first
    [RRTeamGenerator generateTeams];
    
    RRRosterViewController *viewController = [[RRRosterViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
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
    
    [RRDataManager reset];
    [self loadData];
    
    UIAlertView *erasedAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"The registration data has been erased." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [erasedAlertView show];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.riders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RRRiderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRRRegistrationRiderCell forIndexPath:indexPath];    
    [cell setRider:self.riders[indexPath.row]];
    
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
    [viewController setRider:self.riders[indexPath.row]];
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
        [RRDataManager destroyObject:self.riders[indexPath.row]];
        [self loadData];
    }
}

@end
