//
//  WidgetViewController.h
//  sema2
//
//  Created by Starehe Harrison on 17/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Question.h"
#import "AnswerSet.h"

@protocol QuestionDelegate<NSObject>
- (void)isValid:(BOOL)isValid;
@end

@interface WidgetViewController : UIViewController

@property (retain, nonatomic) Question *question;
@property AnswerSet *answerSet;

@property NSInteger dbSurveyId;
@property NSInteger dbQuestionSetId;
@property NSInteger dbQuestionId;
@property NSString *answerValue;

@property long long displayedTimestamp;
@property long long answeredTimestamp;

@property (assign, nonatomic) long long startHRTimestamp;
@property (assign, nonatomic) long long reactionTimeMs;

@property (assign, nonatomic) id<QuestionDelegate> delegate;

@property (retain, nonatomic) NSDictionary *attribs;
@property (retain, nonatomic) UIFont *boldFont;
@property (retain, nonatomic) UIFont *emFont;

- (void)saveQuestionToDB;
- (void)incrementQuestionIndex;

@end
