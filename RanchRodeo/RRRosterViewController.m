//
//  RRRosterViewController.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/22/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRRosterViewController.h"

@interface RRRosterViewController ()
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *teams;
@end

@implementation RRRosterViewController

NSString * const kTeamCollectionViewCell = @"teamCollectionViewCell";
NSInteger const kViewTagTeamNumberLabel = 101;
NSInteger const kViewTagRiderNameLabel = 201;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setTitle:@"Roster"];
    }
    return self;
}

- (void)viewDidLoad
{
    UINib *cellNib = [UINib nibWithNibName:@"RRTeamCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:kTeamCollectionViewCell];
    
    [self loadData];
}

- (void)loadData
{
    [self setTeams:[RRDataManager allTeams]];
    [self.collectionView reloadData];
    [self updateDisplay];
}

- (void)updateDisplay
{
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.teams.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTeamCollectionViewCell forIndexPath:indexPath];
    
    UILabel *teamNumberLabel = (UILabel *)[cell viewWithTag:kViewTagTeamNumberLabel];
    Team *team = (Team *)[self.teams objectAtIndex:indexPath.row];
    [teamNumberLabel setText:[NSString stringWithFormat:@"%i", team.number.intValue]];
    
    NSArray *riders = team.riders.allObjects;
    for (int i = 0; i < riders.count; i++)
    {
        Rider *rider = [riders objectAtIndex:i];
        UILabel *riderNameLabel = (UILabel *)[cell viewWithTag:(kViewTagRiderNameLabel + i)];
        [riderNameLabel setText:[NSString stringWithFormat:@"%@ %@", rider.firstName, rider.lastName]];
    }
    
    return cell;
}

@end
