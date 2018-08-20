//
//  RRPrintRenderer.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 6/17/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRPrintRenderer.h"
#import "RRTeamCollectionPrintViewCell.h"
#import "RRTeamGenerator.h"

@interface RRPrintRenderer()

@property (nonatomic, strong) NSArray *teams;
@property (nonatomic) int currentPage;
@property (nonatomic, strong) UIImage *currentPageImage;

@end

@implementation RRPrintRenderer

static const int TEAMS_PER_PAGE = 12; // 4 rows of 3 teams
NSString * const kTeamCollectionPrintViewCell = @"teamCollectionPrintViewCell";

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.headerHeight = 36.0f;
        self.footerHeight = 0.0f;
        self.currentPage = 0;
        [self loadData];
    }
    
    return self;
}

- (void)loadData
{
    [self setTeams:[[RRDataManager sharedRRDataManager] allTeams]];
}

- (NSInteger)numberOfPages
{
    int numberOfTeams = (int)self.teams.count;
    int numberOfPages = ceil((float)numberOfTeams / TEAMS_PER_PAGE);
    return numberOfPages;
}

- (void)drawHeaderForPageAtIndex:(NSInteger)pageIndex  inRect:(CGRect)headerRect
{
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12.0];
    NSDictionary *attrsDictionary =
    [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    CGSize titleSize = [self.jobTitle sizeWithAttributes:attrsDictionary];
    CGFloat drawX = CGRectGetMaxX(headerRect)/2 - titleSize.width/2;
    CGFloat drawY = headerRect.origin.y + ((headerRect.size.height - titleSize.height) / 2.0f);
    CGPoint drawPoint = CGPointMake(drawX, drawY);
    
    [self.jobTitle drawAtPoint:drawPoint withAttributes:attrsDictionary];
}

- (void)drawContentForPageAtIndex:(NSInteger)pageIndex inRect:(CGRect)contentRect
{
    self.currentPage = (int)pageIndex;
    [self makeImageWithSize: contentRect];
    [self.currentPageImage drawInRect:contentRect];
}

- (void)makeImageWithSize:(CGRect)contentRect {
    runOnMainQueueWithoutDeadlocking(^{
        UIGraphicsBeginImageContext(contentRect.size);
        
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.itemSize = CGSizeMake(180.0f, 160.0f);
        collectionViewLayout.minimumLineSpacing = (contentRect.size.height - (160.0f * 4.0f)) / 3.0f; // change this if teams per page changes
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:contentRect collectionViewLayout:collectionViewLayout];
        [collectionView registerClass:[RRTeamCollectionPrintViewCell class] forCellWithReuseIdentifier:kTeamCollectionPrintViewCell];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        
        [collectionView drawViewHierarchyInRect:contentRect afterScreenUpdates:YES];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        self.currentPageImage = image;
    });
}

#pragma mark - Collection Data Source


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return MIN(self.teams.count - (self.currentPage * TEAMS_PER_PAGE), TEAMS_PER_PAGE);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RRTeamCollectionPrintViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTeamCollectionPrintViewCell forIndexPath:indexPath];
    
    int teamIndex = (int)((self.currentPage * TEAMS_PER_PAGE) + indexPath.row);
    Team *team = (Team *)[self.teams objectAtIndex:teamIndex];
    [cell.teamNumberLabel setText:[NSString stringWithFormat:@"%i", team.number.intValue]];
    
    NSArray *riders = team.riders.allObjects;
    for (int i = 0; i < [[RRTeamGenerator sharedRRTeamGenerator] ridersPerTeam]; i++)
    {
        UILabel *riderNameLabel = [cell riderNameLabelByNumber:i];
        if (riders.count > i)
        {
            Rider *rider = [riders objectAtIndex:i];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"show_rider_details"])
            {
                [riderNameLabel setText:rider.description];
            }
            else
            {
                [riderNameLabel setText:rider.fullName];
            }
            
            if ([[rider isWaiverSigned] boolValue]) {
                [riderNameLabel setTextColor:[UIColor blackColor]];
            }
            else
            {
                [riderNameLabel setTextColor:[UIColor redColor]];
            }
        }
        else
        {
            [riderNameLabel setText:@"AVAILABLE"];
            [riderNameLabel setTextColor:[UIColor redColor]];
        }
    }
    
    return cell;
}

@end
