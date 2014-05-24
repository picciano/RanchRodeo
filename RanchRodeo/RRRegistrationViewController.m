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

@interface RRRegistrationViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRidersLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRidesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfTeamsLabel;

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setRiders:[[RRDataManager sharedRRDataManager] allRiders]];
    [self.tableView reloadData];
}

- (IBAction)createRider:(id)sender
{
    RRRiderViewController *viewController = [[RRRiderViewController alloc] initWithNibName:nil bundle:nil];
    [viewController setRider:[[RRDataManager sharedRRDataManager] newRider]];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)viewRoster:(id)sender
{
    RRRosterViewController *viewController = [[RRRosterViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Reset Data

- (void)resetData
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Are you certain that you want to erase all of the registration data? This action cannot be undone.\n\nEnter \"%@\" to confirm this action.", kRRRegistrationEraseChallengeText] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Clear all", nil];
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
    
    UIAlertView *erasedAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"The registration data has been erased." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [erasedAlertView show];
}

#pragma mark - UITableViewDataSource methods

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
}

@end
