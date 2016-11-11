//
//  BHBlockTableViewController.h
//  btq
//
//  Created by Ashemah Harrison on 1/05/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHBlockTable.h"

@interface BHBlockTableViewController : UIViewController
@property (retain, nonatomic) BHBlockTable *blockTable;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@end
