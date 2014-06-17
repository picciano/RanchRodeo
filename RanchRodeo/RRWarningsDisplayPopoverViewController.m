//
//  RRWarningsDisplayPopoverViewController.m
//  RanchRodeo
//
//  Created by Anthony Picciano on 6/17/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import "RRWarningsDisplayPopoverViewController.h"

@interface RRWarningsDisplayPopoverViewController ()

@property (nonatomic, weak) IBOutlet UITextView *warningTextView;
@property (nonatomic, strong) Team *team;

@end

@implementation RRWarningsDisplayPopoverViewController

- (id)initWithTeam:(Team *)team
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.team = team;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableString *warnings = [[NSMutableString alloc] init];
    for (Warning *warning in self.team.warnings)
    {
        [warnings appendString:warning.message];
        [warnings appendString:@"\n"];
    }
    
    self.warningTextView.text = warnings;
}

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(300.0f, 100.0f);
}

@end
