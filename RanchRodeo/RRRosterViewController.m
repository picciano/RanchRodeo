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
#import "RRTeamGenerator.h"
#import "RREditTeamViewController.h"

@interface RRRosterViewController ()
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *teams;
@property (nonatomic, strong) UIPopoverController *popOverController;
@property (nonatomic, strong) UIBarButtonItem *regenerateTeamsButton;
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
        self.regenerateTeamsButton = [[UIBarButtonItem alloc] initWithTitle:@"Regenerate Teams" style:UIBarButtonItemStylePlain target:self action:@selector(regenerateTeams:)];
        
        [self.navigationItem setRightBarButtonItems:@[self.printButton, self.regenerateTeamsButton]];
    }
    return self;
}

- (void)regenerateTeams:(id)sender
{
    [[RRTeamGenerator sharedRRTeamGenerator] generateTeams];
    [self loadData];
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
    controller.printPageRenderer = printRenderer;
    
    [controller presentFromBarButtonItem:self.printButton animated:YES completionHandler:completionHandler];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerClass:[RRTeamCollectionViewCell class] forCellWithReuseIdentifier:kTeamCollectionViewCell];
    [self loadData];
}

- (void)loadData
{
    [self setTeams:[[RRDataManager sharedRRDataManager] allTeams]];
    [self updateDisplay];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateDisplay];
}

- (void)updateDisplay
{
    [self.collectionView reloadData];
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
    
    cell.editButton.tag = team.number.intValue - 1;
    [cell.editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableArray *riders = team.riders.allObjects.mutableCopy;
    [riders sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES],
                                   [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
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

- (void)warningButtonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    long tag = button.tag;
    
    CGRect superviewframe = button.superview.superview.frame;
    CGRect rect = button.frame;
    rect.origin.x += superviewframe.origin.x;
    rect.origin.y += superviewframe.origin.y;
    
    RRWarningsDisplayPopoverViewController *viewController = [[RRWarningsDisplayPopoverViewController alloc] initWithTeam:[self.teams objectAtIndex:tag]];
    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
    [self.popOverController presentPopoverFromRect:rect inView:self.collectionView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)editButtonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    long tag = button.tag;
    
    RREditTeamViewController *viewController = [[RREditTeamViewController alloc] initWithNibName:nil bundle:nil];
    [viewController setTeam:[self.teams objectAtIndex:tag]];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
