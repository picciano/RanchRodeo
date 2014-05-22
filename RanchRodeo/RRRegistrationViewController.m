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

@interface RRRegistrationViewController ()

- (IBAction)createRider:(id)sender;
- (IBAction)viewRoster:(id)sender;

@end

@implementation RRRegistrationViewController

NSString * const kRRRegistrationEraseChallengeText = @"erase";

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setTitle:@"Registration"];
        
        UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(resetData)];
        [self.navigationItem setRightBarButtonItem:resetItem];
    }
    return self;
}

- (IBAction)createRider:(id)sender
{
    RRRiderViewController *viewController = [[RRRiderViewController alloc] initWithNibName:nil bundle:nil];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confiration" message:[NSString stringWithFormat:@"Are you certain that you want to delete all of the registration data? This action cannot be undone.\n\nType \"%@\" to confirm this action.", kRRRegistrationEraseChallengeText] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Clear all", nil];
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
        return;
    }
    
    UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:@"Confiration" message:@"Registrationdata has been deleted." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView2 show];
}

@end
