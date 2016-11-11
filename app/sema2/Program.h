//
//  Program.h
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <Realm/Realm.h>

#import "AnswerSet.h"
#import "Survey.h"

@interface Program : RLMObject

@property NSString *displayName;
@property NSString *desc;

@property NSString *contactName;
@property NSString *contactEmail;
@property NSString *contactNumber;

@property NSInteger dbProgramId;
@property NSInteger dbVersionId;

@property NSInteger versionNumber;

@property long long createdTimestamp;
@property long long updatedTimestamp;

@property BOOL needsSetup;

@property RLMArray<AnswerSet> *answers;
@property RLMArray<Survey> *surveys;

@end
RLM_ARRAY_TYPE(Program)