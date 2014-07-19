//
//  RREditTeamViewController.h
//  RanchRodeo
//
//  Created by Anthony Picciano on 7/14/14.
//  Copyright (c) 2014 Anthony Picciano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RREditTeamViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) Team *team;

@end
