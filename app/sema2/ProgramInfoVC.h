//
//  ProjectInfoVC.h
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHBLockTable.h"
#import "Program.h"
#import <MessageUI/MessageUI.h>

@interface ProgramInfoVC : UIViewController <MFMailComposeViewControllerDelegate>

@property (assign, nonatomic) NSInteger programId;
@property (retain, nonatomic) Program *program;
@property (retain, nonatomic) BHBlockTable *blockTable;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) BHBlockTableStaticSection *blocks;

@end
