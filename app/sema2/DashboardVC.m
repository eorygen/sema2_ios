//
//  DashboardVC.m
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "DashboardVC.h"
#import "SEMA2API.h"
#import "AnswerSet.h"
#import "Survey.h"
#import "SurveyCell.h"
#import "SurveyVC.h"
#import "Program.h"
#import "ProgramCell.h"
#import "ProgramInfoVC.h"
#import "AppDelegate.h"
#import "CWStatusBarNotification.h"
#import "UIAlertView+Blocks.h"
#import "Constants.h"

#define kStatus @"status"

#define kDashboardTimeout 15

@interface DashboardVC ()

@end

@implementation DashboardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.notification = [[CWStatusBarNotification alloc] init];
    
    BHBlockTableWeakSelf weakSelf = self;
    
    self.blockTable = [[BHBlockTable alloc] initWithTableView:self.tableView];
    [self.tableView setBounces:NO];
    
    // Survey Section
    self.surveySection = [self.blockTable dynamicSectionWithCellIdentifier:@"SurveyCell" headerViewClass:@"BasicHeader" andVisibility:YES];
    
    self.surveySection.emptyCellIdentifier = @"EmptySurveyCell";
    
    self.surveySection.configureCellForRow =^(BHBlockTableInfo *info) {
        
        if (info.row < [self.surveyItems count]) {
            
            SurveyCell *cell = info.cell;
            AnswerSet *set = [weakSelf.surveyItems objectAtIndex:info.row];
            cell.displayName.text = set.survey.program.displayName;
            
            if (set.answerTriggerMode == AnswerSetTriggerModeScheduled) {
                
                long long curTimestamp = (set.expiryTimestamp - [SEMA2API currentTimestamp]) / 60.0;
                int minutes = (int)ceil(curTimestamp/1000.0);
                
                NSString *message = (minutes == 1) ? @"This survey expires in 1 minute" : [NSString stringWithFormat:@"This survey expires in %d minutes", minutes];
                
                if (set.survey.maxIterations == -1) {
                    cell.infoLabel.text = [NSString stringWithFormat:@"# %ld - %@", (long)set.iteration, message];
                }
                else {
                    cell.infoLabel.text = [NSString stringWithFormat:@"# %ld / %ld - %@", (long)set.iteration, (long)set.survey.maxIterations, message];
                }
                
            }
            else if (set.answerTriggerMode == AnswerSetTriggerModeAdHoc) {
                
                NSString *message = @"This survey can be launched anytime";
                cell.infoLabel.text = message;
                
            }
        }
        else {
            NSLog(@"Foo");
        }
    };
    
    self.surveySection.numberOfRows =^NSInteger(BHBlockTableInfo *info) {
        return [weakSelf.surveyItems count];
    };
    
    self.surveySection.configureHeaderView = ^(BHBlockTableInfo *info) {
        [[info view] setTitle:@"Active Surveys"];
    };
    
    self.surveySection.didSelectRow =^void(BHBlockTableInfo *info) {
        
        if ([weakSelf.surveyItems count] > 0) {
            
            weakSelf.launchedAnswerSet = [weakSelf.surveyItems objectAtIndex:weakSelf.surveySection.info.row];
            [weakSelf performSegueWithIdentifier:@"StartSurvey" sender:weakSelf];
        }
    };
    
    // Program Section
    self.programSection = [self.blockTable dynamicSectionWithCellIdentifier:@"ProgramCell" headerViewClass:@"BasicHeader" andVisibility:YES];
    self.programSection.emptyCellIdentifier = @"EmptyProgramCell";
    
    self.programSection.configureCellForRow =^(BHBlockTableInfo *info) {
        
        ProgramCell *cell = info.cell;
        Program *program = [weakSelf.programItems objectAtIndex:info.row];
        
        cell.statusLabel.text = [[SEMA2API sharedClient] calcStatus:program];
        cell.displayName.text = program.displayName;
    };
    
    self.programSection.numberOfRows =^NSInteger(BHBlockTableInfo *info) {
        return [weakSelf.programItems count];
    };
    
    self.programSection.configureHeaderView = ^(BHBlockTableInfo *info) {
        [[info view] setTitle:@"Programs"];
    };
    
    self.programSection.didSelectRow =^void(BHBlockTableInfo *info) {
        
        if ([weakSelf.programItems count] > 0) {
            [weakSelf performSegueWithIdentifier:@"ViewInfo" sender:weakSelf];
        }
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDidStart:) name:kSyncStateStarted object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDidComplete:) name:kSyncStateCompleted object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDidCompleteWithError:) name:kSyncStateError object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(launchStuff) name:kLaunchSurvey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kRefreshDashboard object:nil];
    
    //
    [self launchStuff];
    
    if (![[SEMA2API sharedClient] hasValidAuthToken]) {
        [self performSegueWithIdentifier:@"SignOut" sender:self];
    }
}

- (IBAction)diagnosticsTapped:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Diagnostics" message:@"Please enter the admin password to continue" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *password = [[alertView textFieldAtIndex:0] text];
    
    if ([password isEqualToString:@"fan"]) {
        [self performSegueWithIdentifier:@"diagnostics" sender:self];
    }
}

- (void)performSync {
    [[SEMA2API sharedClient] runSync];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[SEMA2API sharedClient] enableSync];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    self.token = [realm addNotificationBlock:^(NSString *note, RLMRealm * realm) {
        [self refreshData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm removeNotification:self.token];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [delegate.uplink checkForUpdates:YES];
    
    [self refreshDashboard];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self disableTimer];
}

- (IBAction)signOutTapped:(id)sender {
    
    [[SEMA2API sharedClient] signOut];
    [self performSegueWithIdentifier:@"SignOutAnim" sender:self];
}

- (void)launchStuff {
    
    if ([SEMA2API sharedClient].launchedAnswerSetUUID != nil) {
        
        RLMResults *answerSets = [AnswerSet objectsWhere:@"uuid == %@", [SEMA2API sharedClient].launchedAnswerSetUUID];
        self.launchedAnswerSet = [answerSets firstObject];
        
        long long expiryTimestamp = self.launchedAnswerSet.expiryTimestamp;
        long long curTimestamp = [SEMA2API currentTimestamp];
        
        if (expiryTimestamp > curTimestamp) {
            
            if (self.launchedAnswerSet.completedTimestamp == -1) {
                [self performSegueWithIdentifier:@"StartSurvey" sender:self];
            }
        }
        else {
            [UIAlertView showWithTitle:@"Survey Expired" message:@"This survey has expired" cancelButtonTitle:@"Close" otherButtonTitles:nil tapBlock:nil];
        }
        
        [SEMA2API sharedClient].launchedAnswerSetUUID = nil;
    }
}

- (void)onTimeout {
    [self refreshDashboard];
}

- (void)refreshDashboard {
    
    [self resetTimer];
    
    [self refreshSyncStatus];
    [self refreshData];
    [self recalculateStreak];
}

- (void)resetTimer {
    
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kDashboardTimeout target:self selector:@selector(onTimeout) userInfo:nil repeats:YES];
}

- (void)disableTimer {
    
    [self.timer invalidate];
    self.timer = nil;
}

- (void)appDidEnterBackground:(UIApplication *)application {
    
    [self disableTimer];
}

- (void)appDidBecomeActive:(UIApplication *)application {
    
    [self refreshDashboard];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ViewInfo"]) {
        Program *program = self.programItems[self.programSection.info.row];
        ((ProgramInfoVC*)segue.destinationViewController).programId = program.dbProgramId;
    }
    else if ([segue.identifier isEqualToString:@"StartSurvey"]) {
        
        NSLog(@"**** prepareForSegue - launching AnswerSet (%@)", self.launchedAnswerSet.uuid);
        
        UINavigationController *navController = (UINavigationController*)segue.destinationViewController;
        navController.delegate = self;
        ((SurveyVC*)navController.topViewController).answerSet = self.launchedAnswerSet;
    }
}

- (NSInteger)getRemainingAnswerSetCount {
    
    long long curTimestamp = [SEMA2API currentTimestamp];
    
    RLMResults *remainingAnswerSets = [AnswerSet objectsWhere:@"uploadedTimestamp == -1 AND deliveryTimestamp != -1 AND deliveryTimestamp < %@ AND ((completedTimestamp != -1 AND completedTimestamp < %@) OR (expiryTimestamp != -1 AND expiryTimestamp < %@))", @(curTimestamp), @(curTimestamp), @(curTimestamp)];
    
    return [remainingAnswerSets count];
}

- (void)syncDidStart:(id)notification {
    
    [self disableSyncButton];
    [self.notification displayNotificationWithMessage:@"Synchronising..." forDuration:10];
    [self refreshSyncStatus];
}

- (void)enableSyncButton {
    
    [self.syncButton setAlpha:1.0];
    [self.syncButton setEnabled:YES];
}

- (void)disableSyncButton {
    
    [self.syncButton setAlpha:0.4];
    [self.syncButton setEnabled:NO];
}

- (void)syncDidCompleteWithError:(id)notification {
    
    [self refreshDashboard];
    
    [self enableSyncButton];
}

- (void)syncDidComplete:(id)notification {
    
    [self.notification dismissNotification];
    
    [self refreshDashboard];
    
    [self enableSyncButton];
}

- (void)refreshSyncStatus {
    
    if ([SEMA2API sharedClient].isSynchronising) {
        [self.syncStatusLabel setText:@"Synchronising..."];
    }
    else {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSInteger lastSyncStartTimestamp = [[prefs valueForKey:kSyncDataStartTimestamp] integerValue];
        NSInteger lastSyncEndTimestamp = [[prefs valueForKey:kSyncDataEndTimestamp] integerValue];
        BOOL lastSyncOffline = [[prefs valueForKey:kSyncDataOffline] boolValue];
        BOOL lastSyncServerTestFailed = [[prefs valueForKey:kSyncDataServerTestFailed] boolValue];
        NSInteger lastSyncCount = [[prefs valueForKey:kSyncDataCount] integerValue];
        NSInteger lastSyncSendCount = [[prefs valueForKey:kSyncDataSendCount] integerValue];
        
        NSString *timeSinceStartTime = [SEMA2API wordedTimeSinceTimestamp:lastSyncStartTimestamp];
        NSString *timeSinceEndTime = [SEMA2API wordedTimeSinceTimestamp:lastSyncEndTimestamp];
        
        NSInteger remainingAnswerSetCount = [self getRemainingAnswerSetCount];
        
        BOOL showRemaining = YES;
        
        NSString *result = @"";
        if (lastSyncOffline) {
            result = [NSString stringWithFormat:@"Sync failed %@. Device was offline. ", timeSinceStartTime];
        }
        else if (lastSyncServerTestFailed) {
            result = [NSString stringWithFormat:@"Sync failed %@. Unable to connect. ", timeSinceStartTime];
        }
        else {
            result = [NSString stringWithFormat:@"Synced %@. ", timeSinceEndTime];
        }
        
        NSString *uploads = @"";
        if (lastSyncSendCount < lastSyncCount) {
            uploads = [NSString stringWithFormat:@"%ld of %ld surveys uploaded. ", (long)lastSyncSendCount, (long)lastSyncCount];
            showRemaining = NO;
        }
        else if (lastSyncSendCount == 1) {
            uploads = [NSString stringWithFormat:@"1 survey uploaded. "];
        }
        else if (lastSyncSendCount > 1) {
            uploads = [NSString stringWithFormat:@"%ld surveys uploaded. ", (long)lastSyncSendCount];
        }
        
        NSString *remaining = @"";
        if (showRemaining) {
            if (remainingAnswerSetCount == 1) {
                remaining = [NSString stringWithFormat:@"1 survey to upload"];
            }
            else if (remainingAnswerSetCount > 1) {
                remaining = [NSString stringWithFormat:@"%ld surveys to upload", (long)remainingAnswerSetCount];
            }
        }
        
        NSString *syncStatus = [NSString stringWithFormat:@"%@%@%@", result, uploads, remaining];
        [self.syncStatusLabel setText:syncStatus];
    }
}

- (void)refreshData {
    
    //
    NSLog(@"Refreshing table data");
    
    //
    NSNumber *curTimestamp = [NSNumber numberWithLongLong:[SEMA2API currentTimestamp]];
    NSLog(@"%@", curTimestamp);
    
    self.surveyItems = [AnswerSet objectsWhere:
                        @"survey != nil AND uploadedTimestamp == -1 AND completedTimestamp == -1 AND deliveryTimestamp <= %@ AND (expiryTimestamp == -1 OR expiryTimestamp > %@)"
                        , curTimestamp, curTimestamp];
    
    // NSInteger count = [self.surveyItems count];
    
    self.programItems = [Program allObjects];
    
    [self.blockTable refresh];
}

- (void)recalculateStreak {
    
    long long curTimestamp = [SEMA2API currentTimestamp];
    
    // Calculate streak by working backwards from most recent survey that has been completed until you reach one that has expired
    RLMResults *expiredAnswerSets = [[AnswerSet objectsWhere:@"answerTriggerMode == %d AND completedTimestamp == -1 AND expiryTimestamp != -1 AND expiryTimestamp < %@", AnswerSetTriggerModeScheduled, @(curTimestamp)] sortedResultsUsingProperty:@"expiryTimestamp" ascending:NO];
    AnswerSet *lastExpiredAnswerSet = [expiredAnswerSets firstObject];
    
    RLMResults *completedAnswerSets = [[AnswerSet objectsWhere:@"answerTriggerMode == %d AND completedTimestamp != -1", AnswerSetTriggerModeScheduled, @(curTimestamp)] sortedResultsUsingProperty:@"completedTimestamp" ascending:NO];
    
    NSInteger currentStreak;
    if (lastExpiredAnswerSet == nil) {
        
        currentStreak = [completedAnswerSets count];
    }
    else {
        
        long long lastExpiredTimestamp = lastExpiredAnswerSet.expiryTimestamp;
        
        currentStreak = 0;
        for (AnswerSet *set in completedAnswerSets) {
            
            if (set.completedTimestamp < lastExpiredTimestamp) {
                
                // Expired so stop counting
                break;
            }
            
            // Completed so increment the count
            currentStreak++;
        }
    }
    
    // Check if a new longest streak has occured and if so, update user defaults
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSInteger longestStreak = [preferences integerForKey:@"longest_streak"];
    if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
    }
    [preferences setInteger:longestStreak forKey:@"longest_streak"];
    [preferences synchronize];
    
    [self.currentStreakLabel setText:[NSString stringWithFormat:@"%ld", (long)currentStreak]];
    [self.longestStreakLabel setText:[NSString stringWithFormat:@"%ld", (long)longestStreak]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)syncTapped:(id)sender {
    
    SEMA2API *api = [SEMA2API sharedClient];
    
    if (!api.isOnline) {
        
        [UIAlertView showWithTitle:@"Offline" message:@"Please go online to sync" cancelButtonTitle:@"Cancel" otherButtonTitles:nil tapBlock:nil];
    }
    else if ([api allowSync] && api.isSynchronising == NO) {
        
        [self disableTimer];
        
        [api runSync];
    }
}

- (IBAction)handleUnwind:(UIStoryboardSegue*)segue {
    
    if ([segue.identifier isEqualToString:@"SignedIn"]) {
        [self performSelector:@selector(performSync) withObject:nil afterDelay:2];
    }
    else if ([segue.identifier isEqualToString:@"SignedOut"]) {
        
        [self performSelector:@selector(signOutTapped:) withObject:nil afterDelay:0.1];
    }
}

@end
