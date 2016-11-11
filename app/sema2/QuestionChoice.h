//
//  QuestionChoice.h
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <Realm/Realm.h>

@interface QuestionChoice : RLMObject

@property NSInteger dbChoiceId;
@property NSString *choiceText;

@end
RLM_ARRAY_TYPE(QuestionChoice)
