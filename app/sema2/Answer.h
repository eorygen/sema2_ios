//
//  Answer.h
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <Realm/Realm.h>

@class AnswerSet;

@interface Answer : RLMObject

@property NSInteger dbSurveyId;
@property NSInteger dbQuestionSetId;
@property NSInteger dbQuestionId;
@property NSString *answerValue;

@property long long displayedTimestamp;
@property long long answeredTimestamp;
@property long long reactionTimeMs;

@property AnswerSet *answerSet;

@end
RLM_ARRAY_TYPE(Answer)

