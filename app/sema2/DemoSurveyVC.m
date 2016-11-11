//
//  DemoSurveyVC.m
//  sema2
//
//  Created by Starehe Harrison on 17/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "DemoSurveyVC.h"
#import <FlatUIKit/FlatUIKit.h>
#import "WidgetViewController.h"
#import "SEMA2API.h"
#import "AppDelegate.h"

@interface DemoSurveyVC ()

@end

@implementation DemoSurveyVC

- (void)viewDidLoad {
    [super viewDidLoad];

    // Play audio for demo
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate playSound:@"alert.caf"];
    
    self.orderedQuestions = [[NSMutableArray alloc] init];
    
    RLMArray<QuestionSet> *questionSets = self.survey.questionSets;
    for (QuestionSet *questionSet in questionSets) {
        
        RLMArray<Question> *questions = questionSet.questions;
        for (Question *question in questions) {
            [self.orderedQuestions addObject:question];
        }
    }
    
    self.currentQuestionIndex = 0;
    
    self.nextButton.buttonColor = [UIColor turquoiseColor];
    self.nextButton.shadowColor = [UIColor greenSeaColor];
    self.nextButton.shadowHeight = 3.0f;
    self.nextButton.cornerRadius = 6.0f;
    self.nextButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.nextButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self gotoNextQuestion];
}

- (void)gotoNextQuestion {
    
    self.nextButton.enabled = false;
    
    if (self.currentQuestionIndex == -1) { // TODO: also check if out of bounds
        // survey completed
        [self performSegueWithIdentifier:@"DemoSurveyCompleted" sender:self]; // TODO: add this segue!
    }
    else {
        Question *question = [self.orderedQuestions objectAtIndex: self.currentQuestionIndex];
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
//    vc.answerSet = self.answerSet;
//    vc.dbSurveyId = self.answerSet.dbSurveyId;
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
        [self.nextButton setTitle:@"Complete" forState:UIControlStateNormal];
        // TODO: change color to red or blue
    }
}

- (IBAction)nextTapped:(id)sender {
//    [self.currentVC saveQuestionToDB]; // don't save during demo
    
    self.currentQuestionIndex++;
    if (self.currentQuestionIndex >= [self.orderedQuestions count]) {
        self.currentQuestionIndex = -1; // survey completed
    }
    
    [self gotoNextQuestion];
}

- (BOOL)isLastQuestion {
    return (self.currentQuestionIndex == [self.orderedQuestions count] - 1);
}

- (void)isValid:(BOOL)isValid {
    self.nextButton.enabled = isValid;
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

