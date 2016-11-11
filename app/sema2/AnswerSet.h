//
//  AnswerSet.h
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <Realm/Realm.h>
#import "Answer.h"
#import "Question.h"

@class Survey;

@interface AnswerSet : RLMObject

@property NSInteger dbSurveyId;
@property NSString *uuid;

@property NSInteger dbProgramId;
@property NSInteger dbProgramVersionId;
@property NSInteger iteration;
@property NSInteger answerTriggerMode;

@property long long uploadedTimestamp;
@property long long createdTimestamp;
@property long long deliveryTimestamp;
@property long long expiryTimestamp;
@property long long completedTimestamp;

@property Survey *survey;

@property RLMArray<Answer> *answers;
@property RLMArray<Question> *orderedQuestions;
@property NSInteger currentQuestionIndex;

@property NSString *timezone;

@end

RLM_ARRAY_TYPE(AnswerSet)
