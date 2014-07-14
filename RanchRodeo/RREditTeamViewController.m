//
//  RREditTeamViewController.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 7/14/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RREditTeamViewController.h"

@interface RREditTeamViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *teamButton1;
@property (nonatomic, weak) IBOutlet UIButton *teamButton2;
@property (nonatomic, weak) IBOutlet UIButton *teamButton3;

@property (nonatomic, strong) NSArray *teamsWithMissingRiders;
@property (nonatomic, assign) Rider *selectedRider;

- (IBAction)moveRider:(id)sender;

@end

@implementation RREditTeamViewController

NSString * const kRiderCell = @"riderCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setTitle:@"Edit Team"];
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kRiderCell];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
}

- (void)loadData
{
    [self.tableView reloadData];
    [self setTeamsWithMissingRiders:[[RRDataManager sharedRRDataManager] teamsWithMissingRiders]];
    [self updateDisplay];
}

- (void)updateDisplay
{
    //hide all buttons
    self.teamButton1.hidden = YES;
    self.teamButton2.hidden = YES;
    self.teamButton3.hidden = YES;
    
    if (self.selectedRider)
    {
        int index = 0;
        
        for (Team *team in self.teamsWithMissingRiders)
        {
            // if the team is alread ythe current team, skip
            if (team.number.intValue == self.team.number.intValue)
            {
                continue;
            }
            
            // if the rider is already on the other team, skip
            if ([team.riders containsObject:self.selectedRider])
            {
                continue;
            }
            
            UIButton *button = [self teamButtonByNumber:index];
            [button setTitle:[NSString stringWithFormat:@"Move to team %i", team.number.intValue]  forState:UIControlStateNormal];
            button.tag = team.number.intValue;
            button.hidden = NO;
            index++;
        }
    }
}

- (IBAction)moveRider:(id)sender
{
    UIButton *button = (UIButton *)sender;
    Team *toTeam = [[RRDataManager sharedRRDataManager] teamWithNumber:(int)button.tag];
    [[RRDataManager sharedRRDataManager] moveRider:self.selectedRider fromTeam:self.team toTeam:toTeam];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.team.riders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRiderCell forIndexPath:indexPath];
    
    Rider *rider = (Rider *)[[self.team.riders allObjects] objectAtIndex:indexPath.row];
    [cell.textLabel setText:[rider fullName]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRider = (Rider *)[[self.team.riders allObjects] objectAtIndex:indexPath.row];
    [self updateDisplay];
}

- (UIButton *)teamButtonByNumber:(int)index
{
    UIButton *teamButton = nil;
    
    switch (index)
    {
        case 0:
            teamButton = self.teamButton1;
            break;
            
        case 1:
            teamButton = self.teamButton2;
            break;
            
        case 2:
            teamButton = self.teamButton3;
            break;
            
        default:
            break;
    }
    
    return teamButton;
}


@end
