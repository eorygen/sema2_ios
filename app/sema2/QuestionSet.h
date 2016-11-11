//
//  QuestionSet.h
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <Realm/Realm.h>
#import "Question.h"

@interface QuestionSet : RLMObject

@property RLMArray<Question> *questions;

@property NSInteger dbQuestionSetId;
@property BOOL randomiseDisplayOrder;

@end
RLM_ARRAY_TYPE(QuestionSet)