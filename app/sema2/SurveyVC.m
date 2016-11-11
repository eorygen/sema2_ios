//
//  SurveyVC.m
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "SurveyVC.h"
#import <FlatUIKit/FlatUIKit.h>
#import "WidgetViewController.h"
#import "SEMA2API.h"
#import "UIAlertView+Blocks.h"
#import "DashboardVC.h"
#import "Constants.h"

@interface SurveyVC ()

@end

@implementation SurveyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SEMA2API sharedClient] disableSync];
 
    self.survey = self.answerSet.survey;
    self.orderedQuestions = self.answerSet.orderedQuestions;
    
    if (self.answerSet.answerTriggerMode == AnswerSetTriggerModeAdHoc && self.answerSet.expiryTimestamp == -1) {
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];

        // set the delivery timestamps to the current time
        long long currentTimestamp = [SEMA2API currentTimestamp];
        [self.answerSet setDeliveryTimestamp:currentTimestamp];
        
        // set adhoc survey to expire in 15 minutes time
        long long expiryTimestamp = [SEMA2API addMinutes:15 toTimestamp:currentTimestamp];
        [self.answerSet setExpiryTimestamp:expiryTimestamp];
        
        [realm commitWriteTransaction];
        
    }

    self.nextButton.buttonColor = [UIColor turquoiseColor];
    self.nextButton.shadowColor = [UIColor greenSeaColor];
    self.nextButton.shadowHeight = 3.0f;
    self.nextButton.cornerRadius = 6.0f;
    self.nextButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.nextButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    [[SEMA2API sharedClient] cancelNotificationsForAnswerSet:self.answerSet.uuid];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    long long currentTimestamp = [SEMA2API currentTimestamp];
//    if (self.answerSet.expiryTimestamp != -1 && self.answerSet.expiryTimestamp < currentTimestamp) {
//        [self showExpiryMessage];
//    }
//    else {
//        [self.timer invalidate];
//        self.timer = nil;
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkExpiry) userInfo:nil repeats:YES];
//    }
    
    [self gotoNextQuestion];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)exitIfExpired {
    [self.timer invalidate];
    long long currentTimestamp = [SEMA2API currentTimestamp];
    if (self.answerSet.expiryTimestamp != -1 && self.answerSet.expiryTimestamp < currentTimestamp) {
        [self showExpiryMessage];
    }
    else {
        self.timer = nil;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(exitIfExpired) userInfo:nil repeats:YES];
    }
}

- (void)showExpiryMessage {
    [UIAlertView showWithTitle:@"Survey Expired" message:@"This survey has expired" cancelButtonTitle:@"Return to dashboard" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        [self returnToDashboard];
        
    }];
}

- (void)returnToDashboard {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self performSegueWithIdentifier:@"CancelSurvey" sender:self];
}

- (void)gotoNextQuestion {
    
    [self exitIfExpired];
    
    self.nextButton.enabled = false;

    self.currentQuestionIndex = self.answerSet.currentQuestionIndex;
    
    if (self.currentQuestionIndex == -1 || self.answerSet == nil) { // TODO: also check if out of bounds
        
        if (self.answerSet) {
            // survey completed
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            self.answerSet.completedTimestamp = [SEMA2API currentTimestamp];
            [realm commitWriteTransaction];
        }
        
        [[SEMA2API sharedClient] enableSync];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self performSegueWithIdentifier:@"SurveyCompleted" sender:self];
    }
    else {
        Question *question = [self.orderedQuestions objectAtIndex:self.currentQuestionIndex];
        [self setupQuestion:question];
    }
}

- (void)setupQuestion:(Question*)question {
    
    NSString *vcName;
    
    switch (question.questionType) {
        case 0:
            vcName = @"TextQuestionVC";
            break;
        case 1:
            vcName = @"MultiChoiceQuestionVC";
            break;
        case 2:
            vcName = @"RadioQuestionVC";
            break;
        case 3:
            vcName = @"SliderQuestionVC";
            break;
        default:
            // error
            break;
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WidgetViewController *vc = [sb instantiateViewControllerWithIdentifier:vcName];
    vc.delegate = self;

    // pass values to be used later when creating the answer object
    vc.question = question;
    vc.answerSet = self.answerSet;
    vc.dbSurveyId = self.answerSet.dbSurveyId;
    vc.dbQuestionSetId = question.dbQuestionSetId;
    vc.dbQuestionId = question.dbQuestionId;
    
    self.nextVC = vc;
    
    [self addChildViewController:self.nextVC];
    self.nextVC.view.frame = self.container.bounds;
    
    [self.currentVC willMoveToParentViewController:nil];
    
    if (self.currentVC) {
        
        [self transitionFromViewController:self.currentVC toViewController:self.nextVC duration:0.6 options:UIViewAnimationOptionTransitionCurlUp animations:nil
                                completion:^(BOOL finished) {
                                    
                                    [self.currentVC removeFromParentViewController];
                                    [self.nextVC didMoveToParentViewController:self];
                                    self.currentVC = self.nextVC;
                                }];
    }
    else {
        [self.view addSubview:self.nextVC.view];
        [self.nextVC didMoveToParentViewController:self];
        self.currentVC = self.nextVC;
    }
    
    // check if last question and if so, display the "save and submit" button
    if ([self isLastQuestion]) {
        [self.nextButton setTitle:@"Save and Submit" forState:UIControlStateNormal];
        // TODO: change color to red or blue
    }    
}

- (IBAction)nextTapped:(id)sender {
        
    [self.currentVC saveQuestionToDB];
    [self gotoNextQuestion];
}

- (BOOL)isLastQuestion {
    return (self.currentQuestionIndex == [self.orderedQuestions count] - 1);
}

- (void)isValid:(BOOL)isValid {
    self.nextButton.enabled = isValid;
}

// no longer in use (but could be used to check validity)
- (NSInteger)calculateCurrentQuestionIndex {
    NSInteger i = 0;
    NSInteger numQuestions = [self.orderedQuestions count];
    
    while (i < [self.orderedQuestions count]) {
        
        Question *question = [self.orderedQuestions objectAtIndex:i];
        
        if ([self answerExistsForQuestion:question andAnswerSet:self.answerSet]) {
            i++;
        }
        else {
            return i;
        }
    }
    return -1; // indicates that all questions have been completed already
}

// no longer in use (but could be used to check validity)
- (BOOL)answerExistsForQuestion:(Question*)question andAnswerSet:(AnswerSet*)answerSet {
    RLMResults *existingAnswers = [Answer objectsWhere:@"answerSet.uuid = %@ AND dbQuestionId = %@", answerSet.uuid, @(question.dbQuestionId)];
    if ([existingAnswers count] > 0) {
        return true;
    }
    else {
        return false;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

