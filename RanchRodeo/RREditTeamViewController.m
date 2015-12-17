//
//  RREditTeamViewController.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 7/14/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RREditTeamViewController.h"
#import "Action.h"
#import "RRTeamGenerator.h"
#import "Team+Category.h"

@interface RREditTeamViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *actionTableView;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;

@property (nonatomic, assign) Rider *selectedRider;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic) CGFloat originalTableHeight;

@end

@implementation RREditTeamViewController

NSString * const kRiderCell = @"riderCell";
NSString * const kActionCell = @"actionCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.actions = [NSMutableArray array];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kRiderCell];
    [self.actionTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kActionCell];
    self.title = @"Edit Team";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadData];
}

- (void)loadData {
    [self.tableView reloadData];
    [self updateDisplay];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Force your tableview margins (this may be a bad idea)
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // Force your tableview margins (this may be a bad idea)
    if ([self.actionTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.actionTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.actionTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.actionTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.originalTableHeight = self.actionTableView.frame.size.height;
    [self adjustTableHeight];
}

- (void)adjustTableHeight {
    CGRect frame = self.actionTableView.frame;
    frame.size.height = [self tableView:self.actionTableView numberOfRowsInSection:1] * 44 - 1;
    
    // Adjust table height, but only smaller.
    if (frame.size.height < self.originalTableHeight) {
        self.actionTableView.frame = frame;
        self.actionTableView.scrollEnabled = NO;
    } else {
        frame.size.height = self.originalTableHeight;
        self.actionTableView.frame = frame;
        self.actionTableView.scrollEnabled = YES;
    }
}

- (void)updateDisplay {
    [self.actions removeAllObjects];
    
    if (self.selectedRider) {
        
        NSArray *teamsWithMissingRiders = [[RRDataManager sharedRRDataManager] teamsWithMissingRiders];
        
        for (Team *team in teamsWithMissingRiders) {
            if (team != self.team && ![team.riders containsObject:self.selectedRider]) {
                Action *action = [[Action alloc] init];
                action.type = ActionTypeMove;
                action.riderToMove = self.selectedRider;
                action.fromTeam = self.team;
                action.toTeam = team;
                [self.actions addObject:action];
            }
        }
        
        NSArray *allTeams = [[RRDataManager sharedRRDataManager] allTeams];
        
        for (Team *team in allTeams) {
            if (team != self.team && team.riders.count == 4 && ![team hasRider:self.selectedRider]) {
                for (Rider *rider in team.riders) {
                    if (rider != self.selectedRider) {
                        Action *action = [[Action alloc] init];
                        action.type = ActionTypeSwap;
                        action.riderToMove = self.selectedRider;
                        action.otherRider = rider;
                        action.fromTeam = self.team;
                        action.toTeam = team;
                        [self.actions addObject:action];
                    }
                }
            }
        }
        
        self.actionLabel.text = (self.actions.count == 0)?@"No Actions Available":@"Available Actions";
    } else {
        self.actionLabel.text = @"Select a Rider";
    }
    
    self.actionTableView.hidden = self.actions.count == 0;
    
    [self.actionTableView reloadData];
    [self adjustTableHeight];
}

- (void)performAction:(Action *)action {
    [[RRDataManager sharedRRDataManager] moveRider:action.riderToMove fromTeam:action.fromTeam toTeam:action.toTeam];
    
    if (action.type == ActionTypeSwap) {
        [[RRDataManager sharedRRDataManager] moveRider:action.otherRider fromTeam:action.toTeam toTeam:action.fromTeam];
    }
    
    [[RRTeamGenerator sharedRRTeamGenerator] determineWarnings];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return self.team.riders.count;
    }
    
    return self.actions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRiderCell forIndexPath:indexPath];
        
        Rider *rider = [self.team.riders.allObjects objectAtIndex:indexPath.row];
        cell.textLabel.text = rider.fullName;
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kActionCell forIndexPath:indexPath];
    cell.textLabel.text = [self.actions[indexPath.row] description];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Courtesy of http://stackoverflow.com/questions/25770119/ios-8-uitableview-separator-inset-0-not-working
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    cell.preservesSuperviewLayoutMargins = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        self.selectedRider = [self.team.riders.allObjects objectAtIndex:indexPath.row];
        [self updateDisplay];
        return;
    }
    
    Action *action = self.actions[indexPath.row];
    [self performAction:action];
}

@end
