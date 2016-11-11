//
//  DemoSurveyVC.h
//  sema2
//
//  Created by Starehe Harrison on 17/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>
#import "WidgetViewController.h"
#import "AnswerSet.h"
#import "Survey.h"
#import "Question.h"

@interface DemoSurveyVC : UIViewController<QuestionDelegate>

@property (weak, nonatomic) IBOutlet UIView *container;
//@property (retain, nonatomic) AnswerSet *answerSet;
//@property (assign, nonatomic) NSInteger answerSetId;
@property (retain, nonatomic) Survey *survey;
@property (assign, nonatomic) NSInteger surveyId;
@property (retain, nonatomic) WidgetViewController *nextVC;
@property (weak, nonatomic) IBOutlet FUIButton *nextButton;
@property (retain, nonatomic) WidgetViewController *currentVC;
@property (assign, nonatomic) NSInteger currentQuestionIndex;
@property (retain, nonatomic) NSMutableArray *orderedQuestions;

@end
