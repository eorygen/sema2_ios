//
//  BHBlockTableViewController.m
//  btq
//
//  Created by Ashemah Harrison on 1/05/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import "BHBlockTableViewController.h"

@interface BHBlockTableViewController ()

@end

@implementation BHBlockTableViewController

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.blockTable = [[BHBlockTable alloc] initWithTableView:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
