//
//  RRRosterViewController.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 5/22/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRRosterViewController.h"
#import "RRTeamCollectionViewCell.h"
#import "RRWarningsDisplayPopoverViewController.h"
#import "RRPrintRenderer.h"

@interface RRRosterViewController ()
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *teams;
@property (nonatomic, strong) UIPopoverController *popOverController;
@property (nonatomic, strong) UIBarButtonItem *printButton;
@end

@implementation RRRosterViewController

NSString * const kTeamCollectionViewCell = @"teamCollectionViewCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setTitle:@"Roster"];
        
        self.printButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(print:)];
        [self.navigationItem setRightBarButtonItem:self.printButton];
    }
    return self;
}

- (void)print:(id)sender
{
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        
        if(!completed && error){
            
            NSLog(@"FAILED! due to error in domain %@ with error code %ld",
                  
                  error.domain, (long)error.code);
            
        }
        
    };
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = self.title;
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    printInfo.orientation = UIPrintInfoOrientationPortrait;
    
    controller.printInfo = printInfo;
    controller.showsPageRange = YES;
    
    RRPrintRenderer *printRenderer = [[RRPrintRenderer alloc] init];
    [printRenderer setJobTitle:self.title];
    [printRenderer setCollectionView:self.collectionView];
    controller.printPageRenderer = printRenderer;
    
    [controller presentFromBarButtonItem:self.printButton animated:YES completionHandler:completionHandler];
}

- (void)viewDidLoad
{
    [self.collectionView registerClass:[RRTeamCollectionViewCell class] forCellWithReuseIdentifier:kTeamCollectionViewCell];
    [self loadData];
}

- (void)loadData
{
    [self setTeams:[[RRDataManager sharedRRDataManager] allTeams]];
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
    RRTeamCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTeamCollectionViewCell forIndexPath:indexPath];
    
    Team *team = (Team *)[self.teams objectAtIndex:indexPath.row];
    [cell.teamNumberLabel setText:[NSString stringWithFormat:@"%i", team.number.intValue]];
    
    cell.warningButton.tag = team.number.intValue - 1;
    if (team.warnings.count == 0)
    {
        [cell.warningButton setImage:[UIImage imageNamed:@"Icon-Check"] forState:UIControlStateNormal];
        [cell.warningButton removeTarget:self action:@selector(warningButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [cell.warningButton setImage:[UIImage imageNamed:@"Icon-X"] forState:UIControlStateNormal];
        [cell.warningButton addTarget:self action:@selector(warningButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSArray *riders = team.riders.allObjects;
    for (int i = 0; i < 4; i++)
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

- (void)warningButtonPressed:(id)sender
{
    UIButton *warningButton = (UIButton *)sender;
    long tag = warningButton.tag;
    
    CGRect superviewframe = warningButton.superview.superview.frame;
    CGRect rect = warningButton.frame;
    rect.origin.x += superviewframe.origin.x;
    rect.origin.y += superviewframe.origin.y;
    
    RRWarningsDisplayPopoverViewController *viewController = [[RRWarningsDisplayPopoverViewController alloc] initWithTeam:[self.teams objectAtIndex:tag]];
    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
    [self.popOverController presentPopoverFromRect:rect inView:self.collectionView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

@end
