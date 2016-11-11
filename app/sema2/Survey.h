//
//  Survey.h
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <Realm/Realm.h>
#import "QuestionSet.h"

@class Program;

@interface Survey : RLMObject

@property NSInteger dbSurveyId;
@property NSInteger maxIterations;
@property NSInteger currentIteration;
@property NSInteger scheduleIsActive;
@property NSInteger scheduleStartSendingAtHour;
@property NSInteger scheduleStartSendingAtMinute;
@property NSInteger scheduleStopSendingAtHour;
@property NSInteger scheduleStopSendingAtMinute;
@property NSInteger scheduleRandomOffsetMinutes;
@property NSInteger scheduleExpiryMinutes;
@property NSInteger scheduleIntervalMinutes;
@property NSInteger answerTriggerMode;
@property NSInteger scheduleAllowMonday;
@property NSInteger scheduleAllowTuesday;
@property NSInteger scheduleAllowWednesday;
@property NSInteger scheduleAllowThursday;
@property NSInteger scheduleAllowFriday;
@property NSInteger scheduleAllowSaturday;
@property NSInteger scheduleAllowSunday;

@property Program *program;

@property RLMArray<QuestionSet> *questionSets;

@end

RLM_ARRAY_TYPE(Survey)
