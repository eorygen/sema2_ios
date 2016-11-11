//
//  DashboardVC.h
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHBlockTable.h"
#import <Realm/Realm.h>
#import "AnswerSet.h"
#import "CWStatusBarNotification.h"
#import "LoginVC.h"

@interface DashboardVC : UIViewController<UIAlertViewDelegate>

@property (retain, nonatomic) BHBlockTable *blockTable;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) BHBlockTableDynamicSection *surveySection;
@property (retain, nonatomic) BHBlockTableDynamicSection *programSection;
@property (retain, nonatomic) RLMResults *surveyItems;
@property (retain, nonatomic) RLMResults *programItems;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) AnswerSet *launchedAnswerSet;
@property (weak, nonatomic) IBOutlet UILabel *minStreakLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxStreakLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentStreakLabel;
@property (weak, nonatomic) IBOutlet UILabel *longestStreakLabel;
@property (retain, nonatomic) CWStatusBarNotification *notification;
@property (retain, nonatomic) RLMNotificationToken *token;

@property (weak, nonatomic) IBOutlet UILabel *syncStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *syncButton;

- (IBAction)handleUnwind:(UIStoryboardSegue*)segue;

@end
