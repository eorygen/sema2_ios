//
//  RadioQuestionVC.h
//  sema2
//
//  Created by Ashemah Harrison on 16/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WidgetViewController.h"
#import "BHBlockTable.h"

@interface RadioQuestionVC : WidgetViewController

@property (weak, nonatomic) IBOutlet UILabel *questionText;

@property (retain, nonatomic) BHBlockTable *blockTable;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) BHBlockTableDynamicSection *section;
@property (retain, nonatomic) NSMutableSet *set;
@property (retain, nonatomic) NSMutableArray *items;
@end
