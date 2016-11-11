//
//  Question.h
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <Realm/Realm.h>
#import "QuestionChoice.h"

@interface Question : RLMObject

@property NSInteger dbQuestionId;
@property NSInteger dbQuestionSetId;
@property BOOL randomiseDisplayOrder;

@property NSString *questionText;
@property NSInteger questionType;

@property NSString *maximumLabel;
@property NSInteger maximumValue;

@property NSString *minimumLabel;
@property NSInteger minimumValue;

@property RLMArray<QuestionChoice> *choices;

@end
RLM_ARRAY_TYPE(Question)
