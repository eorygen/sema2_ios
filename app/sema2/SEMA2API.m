//
//  SEMA2API.m
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "SEMA2API.h"

#import "SVProgressHUD.h"
#import "NSDate+SAMAdditions.h"
#import "UIAlertView+Blocks.h"
#import <Realm/Realm.h>
#import "AnswerSet.h"
#import "Program.h"
#import "QuestionSet.h"
#import "QuestionChoice.h"
#import "Question.h"
#import "Constants.h"
#import "Answer.h"
#import <JWTDecode/A0JWTDecoder.h>
#import "NSDate+CupertinoYankee.h"
#import "AppDelegate.h"
#include <sys/time.h>

#ifdef DEBUG
//static NSString * const kAPIBaseURL = @"http://192.168.1.5:8000/api/1/";
static NSString * const kAPIBaseURL = @"https://sema-surveys.com/api/1/";
#else
static NSString * const kAPIBaseURL = @"https://sema-surveys.com/api/1/";
#endif

@implementation SEMA2API

+ (SEMA2API *)sharedClient {
    
    static SEMA2API *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SEMA2API alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURL]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    self.requestSerializer = requestSerializer;
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.versionString  = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    self.buildNumber    = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    
    self.isOnline = YES;
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        self.isOnline = (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN);
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    return self;
}

+ (void)showSpinner:(NSString*)msg {
    [SVProgressHUD showWithStatus:msg maskType:SVProgressHUDMaskTypeBlack];
}

+ (void)hideSpinner {
    [SVProgressHUD dismiss];
}

- (BOOL)hasValidAuthToken {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *authToken = [prefs objectForKey:@"auth_token"];
    
    if (authToken) {
        NSError *error;
        NSDate *expireDate = [A0JWTDecoder expireDateOfJWT:authToken error:&error];
        if ([expireDate timeIntervalSinceNow] > 0) {
            self.authToken = authToken;
            return YES;
        }
        else {
            return NO;
        }
    }
    
    return NO;
}

- (void)signOut {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"auth_token"];
    [prefs synchronize];
    self.authToken = nil;
}

- (void)authenticateWithUsername:(NSString*)username password:(NSString*)password didSucceed:(void(^)())didSucceed didFail:(void(^)(NSString *errorMessage))didFail {
    
    if (!self.authToken) {
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@token/", kAPIBaseURL]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        [request setHTTPMethod:@"POST"];

        NSString *data = [NSString stringWithFormat:@"username=%@&password=%@", username, password];
        NSData *postData = [data dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        [request addValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
        
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            self.authToken = responseObject[@"token"];
           
            //
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setValue:self.authToken forKey:@"auth_token"];
            [prefs synchronize];
            
            didSucceed();
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            didFail(@"An error occurred while signing you in.\nPlease check your username and password and try again.");
        }];
        
        [[NSOperationQueue mainQueue] addOperation:op];
    }
    else {
        didSucceed();
    }
}

- (void)resetPasswordForUsername:(NSString*)email didSucceed:(void(^)())didSucceed didFail:(void(^)(NSString *errorMessage))didFail {
    
    [self POST:@"participants/reset_password/" parameters:@{@"email": email} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        didSucceed();
        
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {

        NSInteger errorCode = [op.response statusCode];
        NSString *errorMsg = @"An error occurred while trying to send you a reminder email.\n\nPlease try again and contact your program manager if the problem persists";
        
        if (errorCode == 400) {
            errorMsg = @"An error occurred while trying to send you a reminder email.\n\nPlease ensure you have entered the email address that was used to sign you up for SEMA and try again";
        }
        
        didFail(errorMsg);
    }];
}

- (id)doSynchronousRawRequest:(NSString*)url params:(id)params method:(NSString*)method timeout:(NSInteger)timeout error:(NSInteger*)errorCode {
    
    *errorCode = 0;
    
    NSError *error;
    
    NSURLResponse * response = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:[NSString stringWithFormat:@"JWT %@", self.authToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accepts"];
    request.timeoutInterval = timeout;
    
    request.HTTPMethod = method;
    
    if (params) {
        NSData *paramData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        request.HTTPBody = paramData;
    }
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    *errorCode = httpResponse.statusCode;
    
    if (!error) {
        id resObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        return resObj;
    }
    else {
        return nil;
    }
}

- (id)doSynchronousRequest:(NSString*)url params:(id)params method:(NSString*)method timeout:(NSInteger)timeout error:(NSInteger*)errorCode {
    
    *errorCode = 0;
    
    NSError *error;
    
    NSString *fullURL = [NSString stringWithFormat:@"%@%@", kAPIBaseURL, url];
    
    NSURLResponse * response = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullURL]];
    [request setValue:[NSString stringWithFormat:@"JWT %@", self.authToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accepts"];
    request.timeoutInterval = timeout;
    
    request.HTTPMethod = method;
    
    if (params) {
        NSData *paramData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        request.HTTPBody = paramData;
    }
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    *errorCode = httpResponse.statusCode;
    
    if (!error) {
        id resObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        return resObj;
    }
    else {
        return nil;
    }
}

- (long long)getHiresTimestamp {
    struct timeval time;
    gettimeofday(&time, NULL);
    long long millis = (time.tv_sec * 1000) + (time.tv_usec / 1000);
    return millis;
}

- (NSString*)dateString:(long long)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000.0];
    return [date sam_ISO8601String];
}

- (NSString*)calcStatus:(Program*)program {
    
    if ([program.surveys count] == 0) {
        return @"Inactive - No surveys are assigned.";
    }
    else {
        
//        long long curTimestamp = [SEMA2API currentTimestamp];
//        RLMResults *sets = [[AnswerSet objectsWhere:@"dbProgramId = %@ and deliveryTimestamp > %@", @(program.dbProgramId), @(curTimestamp)] sortedResultsUsingProperty:@"deliveryTimestamp" ascending:YES];
//        AnswerSet *nextSet = [sets objectAtIndex:0];
//        
//        NSDateFormatter* df = [[NSDateFormatter alloc] init];
//        [df setTimeZone:[NSTimeZone timeZoneWithName:@"Australia/Melbourne"]];
//        [df setDateFormat:@"dd/MM/yyyy HH:mm:ss zzz"];
//        NSDate *date = [NSDate dateWithTimeIntervalSince1970:nextSet.deliveryTimestamp/1000.0];
//        NSString *res = [NSString stringWithFormat:@"Next: %@, Total #: %ld", [df stringFromDate:date], [sets count]];
        
        return @"Active";
    }
}

- (void)disableSync {
    self.allowSync = NO;
}

- (void)enableSync {
    self.allowSync = YES;
}

- (void)runSync {
    [self runSync:NO];
}

- (void)resetLastSyncData {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:kSyncDataStartTimestamp];
    [prefs removeObjectForKey:kSyncDataEndTimestamp];
    [prefs removeObjectForKey:kSyncDataOffline];
    [prefs removeObjectForKey:kSyncDataServerTestFailed];
    [prefs removeObjectForKey:kSyncDataCount];
    [prefs removeObjectForKey:kSyncDataSendCount];
    [prefs synchronize];
}

- (void)setLastSyncStartTimestamp {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@([SEMA2API currentTimestamp]) forKey:kSyncDataStartTimestamp];
    [prefs synchronize];
}

- (void)setLastSyncEndTimestamp {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@([SEMA2API currentTimestamp]) forKey:kSyncDataEndTimestamp];
    [prefs synchronize];
}

- (void)setLastSyncOffline {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@(YES) forKey:kSyncDataOffline];
    [prefs synchronize];
}

- (void)setLastSyncServerTestFailed {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@(YES) forKey:kSyncDataServerTestFailed];
    [prefs synchronize];
}

- (void)runSync:(BOOL)forceUpload {
    
    [self resetLastSyncData];
    
    [self setLastSyncStartTimestamp];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if (!self.allowSync || self.isSynchronising) {
        
        NSLog(@"--- SKIPPED SYNC ---");
        return;
    }
    
    dispatch_queue_t queue = dispatch_queue_create("com.async", 0);
    dispatch_queue_t main = dispatch_get_main_queue();
    
    if (!self.isOnline) {
        
        // We have skipped the sync but still rebuild the notifications
        // if the reason we skipped was due to us being offline
        
        [self setupNotifications];
        
        NSLog(@"--- SKIPPED SYNC ---");
        
        [self setLastSyncOffline];
        
        dispatch_async(main, ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kSyncStateError object:nil];
        });
        return;
    }
    
    //    dispatch_queue_t queue = dispatch_queue_create("com.async", 0);
    //    dispatch_queue_t main = dispatch_get_main_queue();
    
    // Async queue
    dispatch_async(queue, ^{
        
        @try {
            
            self.isSynchronising = YES;
            NSLog(@"--- SYNCHRONISING ---");
            
            // Main Success
            dispatch_async(main, ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kSyncStateStarted object:nil];
            });
            
            long long syncStartTimestamp = [SEMA2API currentTimestamp];
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            
            if ([self connectionWasSuccessful]) {
                
                // Upload answer sets
                [self uploadAnswerSets:realm syncStartTimestamp:syncStartTimestamp forceUpload:forceUpload];
                
                // Check server for updated programs
                NSArray *updatedProgramData = [self checkServerForUpdatedPrograms:realm];
                BOOL shouldRebuild = updatedProgramData != nil;
                
                if (self.allowSync && shouldRebuild) {
                    
                    // Rebuild ALL Programs and Surveys (later we will restrict it to only those programs that have been modified)
                    [self rebuildWithUpdatedProgramData:updatedProgramData syncStartTimestamp:syncStartTimestamp realm:realm];
                }
                
                // Replenish answer sets if getting low
                [self replenishAnswerSets:realm];
            }
            else {
                
                NSLog(@"--- SERVER CONNECTION CHECK FAILED ---");
                
                [self setLastSyncServerTestFailed];
                
                dispatch_async(main, ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSyncStateError object:nil];
                });
            }
        }
        
        @finally {
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            
            // create any adhoc surveys if required
            [realm beginWriteTransaction];
            [self setupAdHocAnswerSets:realm];
            [realm commitWriteTransaction];
            
            // setup notifications
            [self setupNotifications];
            
            self.isSynchronising = NO;
            
            // notify sync completed
            [self setLastSyncEndTimestamp];
            dispatch_async(main, ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kSyncStateCompleted object:nil];
            });
            
            NSLog(@"--- DONE. ---");
        }
    });
}

- (void)uploadAnswerSets:(RLMRealm*)realm syncStartTimestamp:(long long)syncStartTimestamp forceUpload:(BOOL)forceUpload {
    
    NSLog(@"--- UPLOADING COMPLETED AND EXPIRED ANSWER SETS ---");
    
    [realm beginWriteTransaction];
    
    RLMResults *answerSets = nil;
    if (forceUpload) {
        answerSets = [AnswerSet objectsWhere:@"deliveryTimestamp != -1 AND deliveryTimestamp < %@ AND ((completedTimestamp != -1 AND completedTimestamp < %@) OR (expiryTimestamp != -1 AND expiryTimestamp < %@))", @(syncStartTimestamp), @(syncStartTimestamp), @(syncStartTimestamp)];
    }
    else {
        answerSets = [AnswerSet objectsWhere:@"uploadedTimestamp == -1 AND deliveryTimestamp != -1 AND deliveryTimestamp < %@ AND ((completedTimestamp != -1 AND completedTimestamp < %@) OR (expiryTimestamp != -1 AND expiryTimestamp < %@))", @(syncStartTimestamp), @(syncStartTimestamp), @(syncStartTimestamp)];
    }
    long count = [answerSets count];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@(count) forKey:kSyncDataCount];
    [prefs synchronize];
    
    NSInteger sendCount = 0;
    for (long i = count - 1; i >= 0; i--) {
        
        AnswerSet *set = [answerSets objectAtIndex:i];
        
        NSMutableArray *answers = [NSMutableArray array];
        
        for (Answer *answer in set.answers) {
            NSDictionary *answerDict = @{
                                         @"question": @(answer.dbQuestionId),
                                         @"answer_value": answer.answerValue,
                                         @"displayed_timestamp": [self dateString:answer.displayedTimestamp],
                                         @"answered_timestamp": [self dateString:answer.answeredTimestamp],
                                         @"reaction_time_ms": @(answer.reactionTimeMs)
                                         };
            
            [answers addObject:answerDict];
        }
        
        NSDictionary *params = @{
                                 @"survey": [NSNumber numberWithInteger:set.dbSurveyId],
                                 @"uuid": set.uuid,
                                 @"program_version": [NSNumber numberWithInteger:set.dbProgramVersionId],
                                 @"iteration": [NSNumber numberWithInteger:set.iteration],
                                 @"created_timestamp": [self dateString:set.createdTimestamp],
                                 @"delivery_timestamp": [self dateString:set.deliveryTimestamp],
                                 @"expiry_timestamp": [self dateString:set.expiryTimestamp],
                                 @"completed_timestamp": [self dateString:set.completedTimestamp],
                                 @"timezone": set.timezone,
                                 @"answers": answers
                                 };
        
        NSInteger statusCode;
        [self doSynchronousRequest:@"answers/" params:params method:@"POST" timeout:30 error:&statusCode];
        
        if (statusCode >= 201 && statusCode < 300) {

            long long curTimestamp = [SEMA2API currentTimestamp];
            set.uploadedTimestamp = curTimestamp;
            
            sendCount++;
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:@(sendCount) forKey:kSyncDataSendCount];
            [prefs synchronize];
        }
        else {
            
            break;
        }
    }
    
    [realm commitWriteTransaction];
    
    NSLog(@"--- FINISHED UPLOADING COMPLETED AND EXPIRED ANSWER SETS ---");
}

- (BOOL)connectionWasSuccessful {
    
    NSLog(@"--- TESTING SERVER CONNECTION ---");
    
    // Test connection to server
    NSInteger statusCode;
    [self doSynchronousRawRequest:@"https://sema-surveys.com" params:nil method:@"GET" timeout:5 error:&statusCode];
    
    if (statusCode == 200) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSArray*)checkServerForUpdatedPrograms:(RLMRealm*)realm {
    
    NSInteger surveys = [[Survey allObjects] count];
    
    NSLog(@"--- CHECKING SERVER FOR UPDATED PROGRAMS ---");
    
    // Post the program versions info and get back something
    RLMResults *programs = [Program allObjects];
    
    NSMutableArray *programVersions = [NSMutableArray array];
    
    for (Program *program in programs) {
        [programVersions addObject:@{
                                     @"program": [NSNumber numberWithInteger:program.dbProgramId],
                                     @"version": [NSNumber numberWithInteger:program.versionNumber],
                                     }];
    }
    
    NSDictionary *params = @{
                             @"app_platform": @"ios",
                             @"app_build_number": @([self.buildNumber integerValue]),
                             @"app_version_string": self.versionString,
                             @"push_token": [self getDeviceToken],
                             @"program_versions": programVersions
                             };

    NSInteger statusCode;
    NSDictionary *result = [self doSynchronousRequest:@"sync/" params:params method:@"POST" timeout:30 error:&statusCode];
    
    NSArray *updatedProgramData = result[@"programs"];
    
    /*
    // Testing purposed only
    RLMResults *existingPrograms = [Program allObjects];
    BOOL serverHasUpdates = statusCode == 200;
    BOOL shouldForceUpdates = (statusCode == 304 && [existingPrograms count] == 0);
    BOOL hasValidProgramDataFromServer = updatedProgramData != nil;
    */
    
    NSLog(@"--- FINISHED CHECKING SERVER FOR UPDATED PROGRAMS ---");
    
    return updatedProgramData;
}

- (void)rebuildWithUpdatedProgramData:(NSArray*)updatedProgramData syncStartTimestamp:(long long)syncStartTimestamp realm:(RLMRealm*)realm {
    
    NSLog(@"--- REBUILDING PROGRAMS AND SURVEYS ---");
    
    [realm beginWriteTransaction];
    
    // Delete all of the Answer sets that are either Ad Hoc or scheduled for the future
    RLMResults *existingAnswerSets = [AnswerSet objectsWhere:@"(answerTriggerMode == 0 AND deliveryTimestamp > %@) OR (answerTriggerMode == 1)", @(syncStartTimestamp)];
    [realm deleteObjects:existingAnswerSets];
    
    NSInteger surveysBefore = [[Survey allObjects] count];
    
    // Clear question data for existing programs then delete all existing programs
    RLMResults *existingPrograms = [Program allObjects];
    for (Program *program in existingPrograms) {
        [self clearExistingQuestionData:program realm:realm];
    }
    [realm deleteObjects:existingPrograms];

    NSInteger surveysAfter = [[Survey allObjects] count];
    
    // Now iterate through all of the new data
    for (NSDictionary *programDict in updatedProgramData) {
        
        // Create the program
        Program *program = [[Program alloc] init];
        
        program.dbProgramId = [programDict[@"id"] integerValue];
        program.dbVersionId = [programDict[@"version_id"] integerValue];
        program.versionNumber = [programDict[@"version_number"] integerValue];
        program.createdTimestamp = 0;
        program.displayName = programDict[@"display_name"];
        program.desc = programDict[@"description"];
        program.contactName = programDict[@"contact_name"];
        program.contactNumber = programDict[@"contact_number"];
        program.contactEmail = programDict[@"contact_email"];
        
        [realm addObject:program];
        
        NSLog(@"--- PROGRAM %@ ---", program.displayName);
        
        for (NSDictionary *surveyDict in programDict[@"surveys"]) {
            
            Survey *survey = [[Survey alloc] init];
            
            survey.program = program;
            [program.surveys addObject:survey];
            
            survey.dbSurveyId = [surveyDict[@"id"] integerValue];
            survey.maxIterations = [surveyDict[@"max_iterations"] integerValue];
            survey.answerTriggerMode = [surveyDict[@"trigger_mode"] integerValue];
            survey.currentIteration = [surveyDict[@"current_iteration"] integerValue];
            survey.scheduleIsActive = [surveyDict[@"schedule_is_active"] integerValue];
            
            survey.scheduleStartSendingAtHour = [surveyDict[@"schedule_start_sending_at_hour"] integerValue];
            survey.scheduleStartSendingAtMinute = [surveyDict[@"schedule_start_sending_at_minute"] integerValue];
            
            survey.scheduleStopSendingAtHour = [surveyDict[@"schedule_stop_sending_at_hour"] integerValue];
            survey.scheduleStopSendingAtMinute = [surveyDict[@"schedule_stop_sending_at_minute"] integerValue];
            
            survey.scheduleIntervalMinutes = [surveyDict[@"schedule_delivery_interval_minutes"] integerValue];
            survey.scheduleRandomOffsetMinutes = [surveyDict[@"schedule_delivery_variation_minutes"] integerValue];
            survey.scheduleExpiryMinutes = [surveyDict[@"schedule_survey_expiry_minutes"] integerValue];
            
            survey.scheduleAllowSaturday = [surveyDict[@"schedule_allow_saturday"] boolValue];
            survey.scheduleAllowSunday = [surveyDict[@"schedule_allow_sunday"] boolValue];
            survey.scheduleAllowMonday = [surveyDict[@"schedule_allow_monday"] boolValue];
            survey.scheduleAllowTuesday = [surveyDict[@"schedule_allow_tuesday"] boolValue];
            survey.scheduleAllowWednesday = [surveyDict[@"schedule_allow_wednesday"] boolValue];
            survey.scheduleAllowThursday = [surveyDict[@"schedule_allow_thursday"] boolValue];
            survey.scheduleAllowFriday = [surveyDict[@"schedule_allow_friday"] boolValue];
            
            [realm addObject:survey];
            
            for (NSDictionary *questionSetDict in surveyDict[@"question_sets"]) {
                
                QuestionSet *questionSet = [[QuestionSet alloc] init];
                
                questionSet.dbQuestionSetId = [questionSetDict[@"id"] integerValue];
                questionSet.randomiseDisplayOrder = [questionSetDict[@"randomise_question_order"] boolValue];
                
                [realm addObject:questionSet];
                [survey.questionSets addObject:questionSet];
                
                for (NSDictionary *questionDict in questionSetDict[@"questions"]) {
                    
                    Question *question = [[Question alloc] init];
                    
                    question.dbQuestionId = [questionDict[@"id"] integerValue];
                    question.dbQuestionSetId = questionSet.dbQuestionSetId;
                    question.randomiseDisplayOrder = [questionDict[@"randomise_option_order"] integerValue];
                    question.questionType = [questionDict[@"question_type"] integerValue];
                    question.questionText = questionDict[@"question_text"];
                    
                    question.minimumValue = [questionDict[@"minimum_value"] integerValue];
                    question.minimumLabel = questionDict[@"minimum_label"];
                    
                    question.maximumValue = [questionDict[@"maximum_value"] integerValue];
                    question.maximumLabel = questionDict[@"maximum_label"];
                    
                    for (NSDictionary *choiceDict in questionDict[@"options"]) {
                        
                        QuestionChoice *choice = [[QuestionChoice alloc] init];
                        
                        choice.dbChoiceId = [choiceDict[@"id"] integerValue];
                        choice.choiceText = choiceDict[@"label"];
                        
                        [realm addObject:choice];
                        [question.choices addObject:choice];
                    }
                    
                    [realm addObject:question];
                    [questionSet.questions addObject:question];
                }
            }
        }
    }
    
    [realm commitWriteTransaction];
    
    NSLog(@"--- FINISHED REBUILDING PROGRAMS AND SURVEYS ---");
}

- (void)replenishAnswerSets:(RLMRealm*)realm {
    
    NSLog(@"--- REPLENISHING ANSWER SETS ---");
    
    [realm beginWriteTransaction];
    
//    long long curTimestamp = [SEMA2API currentTimestamp];
    NSDate *curDateTime = [NSDate date];
    long long curTimestamp = [SEMA2API dateToTimestamp:curDateTime];
    
    
    // Calculate how many answer sets are remaining (active surveys only)
    RLMResults *surveys = [Survey objectsWhere:@"scheduleIsActive == YES"];
    for (Survey *survey in surveys) {

        RLMResults *currentAnswerSets = [[AnswerSet objectsWhere:@"dbSurveyId == %d AND answerTriggerMode == 0 AND deliveryTimestamp > %@", survey.dbSurveyId, @(curTimestamp)]sortedResultsUsingProperty:@"completedTimestamp" ascending:YES];
        AnswerSet *lastAnswerSet = [currentAnswerSets lastObject];
        NSInteger currentAnswerSetCount = [currentAnswerSets count];

        if (currentAnswerSetCount < kMinScheduledAnswerSetThreshold) {
            
            // Create answer sets (even if no rebuild)
            if (survey.answerTriggerMode == AnswerSetTriggerModeScheduled && [self surveyHasScheduledDays:survey]) {
                
                long numberOfAnswerSetsToCreate;
                if (survey.maxIterations == -1) { // maxIterations of -1 indicates unlimited iterations
                    
                    // Bring the scheduled answer set count back up to the max
                    numberOfAnswerSetsToCreate = kMaxScheduledAnswerSets - currentAnswerSetCount;
                }
                else {
                    
                    // Bring the scheduled answer set count up to the max or the max iterations
                    numberOfAnswerSetsToCreate = MIN(kMaxScheduledAnswerSets - currentAnswerSetCount, survey.maxIterations - survey.currentIteration);
                }
                
                // Get the last answer set for the survey and set the base timestamp to its deliverytimestamp. If there is no last answer set or its delivery date is in the past, set the base timestamp to the current time
                long long baseTimestamp;
                if (currentAnswerSetCount == 0 || lastAnswerSet.deliveryTimestamp < curTimestamp) {
                    
                    baseTimestamp = curTimestamp;
                }
                else {

                    baseTimestamp = lastAnswerSet.deliveryTimestamp;
                }
                
                // Create the answer sets for this survey
                for (int i = 0; i < numberOfAnswerSetsToCreate; i++) {
                
                    // Create answer set
                    AnswerSet *answerSet = [self setupAnswerSetForSurvey:survey program:survey.program realm:realm baseTimestamp:baseTimestamp isFirst:NO]; // was isFirst:i==0 TODO: reimplement this
                    
                    // General scheduling process
                    // If the timestamp is within the schedule bounds then schedule the thing
                    // If the timestamp is less than the schedule start time then work out how many minutes until the schedule start time and add that to the timestamp then schedule the thing
                    // If the timestamp is greater than the schedule start time then:
                    // 1. work out how many minutes to the next day
                    // 2. work out how many minutes until the start time for that day
                    // 3. add that many minutes onto the current timestamp
                    // 4. Schedule the thing from there
                    
                    baseTimestamp = answerSet.deliveryTimestamp;
                }
            }
        }
    }
    
    [realm commitWriteTransaction];
    
    NSLog(@"--- FINISHED REPLENISHING ANSWER SETS ---");
}

- (BOOL)surveyHasScheduledDays:(Survey*)survey {
    
    return (survey.scheduleAllowSunday || survey.scheduleAllowMonday || survey.scheduleAllowTuesday || survey.scheduleAllowWednesday || survey.scheduleAllowThursday || survey.scheduleAllowFriday || survey.scheduleAllowSaturday);
}

- (void)handleNotification:(UILocalNotification*)notif {
    
    NSDictionary *dict = [notif userInfo];
    self.launchedAnswerSetUUID = dict[@"answerSetUUID"];
    
    if (self.didResumeFromBackground) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLaunchSurvey object:nil];
    }
    else {
        // play the notification sound only
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate playSound:@"alert.caf"];
        
        // notify dashboard refresh
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDashboard object:nil];
    }
    
    self.didResumeFromBackground = NO;
}

- (void)storeDeviceToken:(NSData*)token {
    NSString *foo = [[token description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    self.deviceToken = [foo stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.deviceToken forKey:@"device_token"];
    [prefs synchronize];
    
    NSLog(@"TOKEN: %@", self.deviceToken);
}

- (NSString*)getDeviceToken {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *token = [prefs objectForKey:@"device_token"];
    if (!token) {
        token = @"<invalid>";
    }
    return token;
}

- (void)handleRemoteNotification:(NSDictionary*)notif {
    
    NSDictionary *aps = (NSDictionary *)[notif objectForKey:@"aps"];
    
    NSString *type = [notif objectForKey:@"type"];
    NSString *message = [aps objectForKey:@"alert"];
    
    if ([type isEqualToString:@"content_update"]) {
        [self runSync];
    }
}

- (void)handleNormalLaunch {
    self.launchedAnswerSetUUID = nil;
}

- (void)setupAdHocAnswerSets:(RLMRealm*)realm {
    
    long long curTimestamp = [SEMA2API currentTimestamp];
    
    // Get all adhoc surveys
    RLMResults *adhocSurveys = [Survey objectsWhere:@"answerTriggerMode == %d", AnswerSetTriggerModeAdHoc];
    
    for (Survey *adhocSurvey in adhocSurveys) {

        // Check if an active ad hoc answer set exists for this survey
        RLMResults *existingAnswerSets = [AnswerSet objectsWhere:@"dbSurveyId == %@ AND answerTriggerMode == %d AND completedTimestamp == -1 AND (expiryTimestamp == -1 OR expiryTimestamp > %@)", [NSNumber numberWithInteger:adhocSurvey.dbSurveyId], AnswerSetTriggerModeAdHoc, @(curTimestamp)]; // previously used numberWithLongLong
        
        // Proceed if there are remaining iterations
        if ([existingAnswerSets count] == 0 && (adhocSurvey.maxIterations == -1 || adhocSurvey.currentIteration < adhocSurvey.maxIterations)) {
            
            NSDateFormatter* df = [[NSDateFormatter alloc] init];
            [df setTimeZone:[NSTimeZone timeZoneWithName:@"Australia/Melbourne"]];
            [df setDateFormat:@"dd/MM/yyyy '@' HH:mm:ss zzz"];
            
            NSDate *curDateTime = [NSDate date];
            long long baseTimestamp = [SEMA2API dateToTimestamp:curDateTime];
            
            [self setupAnswerSetForSurvey:adhocSurvey program:adhocSurvey.program realm:realm baseTimestamp:baseTimestamp isFirst:YES];
            
        }
        
    }
    
}

- (void)setupNotifications {

    NSLog(@"--- SETTING UP NOTIFICATIONS ---");

    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    long long curTimestamp = [SEMA2API currentTimestamp];
    
    // Get all of the future scheduled answer sets for each survey
    RLMResults *futureScheduledAnswerSets = [[AnswerSet objectsWhere:@"(answerTriggerMode == 0 AND deliveryTimestamp > %@)", @(curTimestamp)] sortedResultsUsingProperty:@"deliveryTimestamp" ascending:YES]; // previously used numberWithLongLong
    
    NSInteger allowedNotifications = [futureScheduledAnswerSets count] / 3; // We are making 3 at a time so we need to divide it by 3
    
    // Schedule an alert for each one
    long count = MIN(kMaxScheduledAlerts, allowedNotifications);
    
    for (int i=0; i < count; i++) {
        
        AnswerSet *set = [futureScheduledAnswerSets objectAtIndex:i];
        [self createNotificationForAnswerSet:set];
        
    }
    
}

- (AnswerSet*)setupAnswerSetForSurvey:(Survey*)survey program:(Program*)program realm:(RLMRealm*)realm baseTimestamp:(long long)baseTimestamp isFirst:(BOOL)isFirst {
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSString *tzName = [timeZone name];
    
    if (!tzName || [tzName length] == 0) {
        tzName = @"Australia/Melbourne";
    }
    
    AnswerSet *set = nil;
    
    if (survey.answerTriggerMode == AnswerSetTriggerModeScheduled) {
        
        // create the answer set
        set = [self createAnswerSetForSurvey:survey program:program realm:realm];
        
        // calculate random offset
        long randomOffset = 0;
        if (survey.scheduleRandomOffsetMinutes > 0) {
            int r = arc4random_uniform((unsigned int)survey.scheduleRandomOffsetMinutes*2);
            randomOffset = -survey.scheduleRandomOffsetMinutes + r;
        }
        
        long minutesFromBaseTimestamp = survey.scheduleIntervalMinutes + randomOffset;
        
        if (isFirst) {
            minutesFromBaseTimestamp = (int)(minutesFromBaseTimestamp * 0.5);
        }
        
        // calculate a proposed time stamp for the answer set
        long long proposedDeliveryTimestamp = [SEMA2API addMinutes:minutesFromBaseTimestamp toTimestamp:baseTimestamp];
        long long validDeliveryTimestamp = -1;
        
        // check that the proposed delivery time falls on an 'allowed day'
        int weekday = [self getDayFromTimestamp:proposedDeliveryTimestamp];
        BOOL dayIsValid = [self isAllowedDay:weekday forSurvey:survey];
        
        if (dayIsValid) { // the day is an 'allowed day'
            
            NSLog(@"** SEMA2API - the proposed day is an allowed day");
            
            NSDate *proposedDate = [SEMA2API timestampToDate:proposedDeliveryTimestamp];
            NSDate *startOfDay = [proposedDate beginningOfDay];
            long long startOfDayTimestamp = [SEMA2API dateToTimestamp:startOfDay];
            
            long scheduleStartAtSeconds = (survey.scheduleStartSendingAtHour * 60 * 60) + (survey.scheduleStartSendingAtMinute * 60);
            NSDate *startAtDateTime = [startOfDay dateByAddingTimeInterval:scheduleStartAtSeconds];
            long long programStartMillis = [SEMA2API dateToTimestamp:startAtDateTime];
            
            long scheduleStopAtSeconds = (survey.scheduleStopSendingAtHour * 60 * 60) + (survey.scheduleStopSendingAtMinute * 60);
            NSDate *stopAtDateTime = [startOfDay dateByAddingTimeInterval:scheduleStopAtSeconds];
            long long programEndMillis = [SEMA2API dateToTimestamp:stopAtDateTime];
            
            if (proposedDeliveryTimestamp < programStartMillis) { // proposed delivery time is before the program's start time
                
                NSLog(@"** SEMA2API - proposed delivery time (%@) is prior to program's start time (%@)", [SEMA2API timestampToDateString:proposedDeliveryTimestamp], [SEMA2API timestampToDateString:programStartMillis]);
//                NSLog(@"** SEMA2API - proposed delivery time (%lld) is prior to program's start time (%lld)", proposedDeliveryTimestamp, programStartMillis);
                
                // set the delivery time to the specified day's start time including positive randomisation
                long positiveOffsetMillis = arc4random_uniform((unsigned int)survey.scheduleRandomOffsetMinutes) * 60 * 1000;
                validDeliveryTimestamp = programStartMillis + positiveOffsetMillis;
                
            }
            else if (proposedDeliveryTimestamp > programEndMillis) { // proposed delivery time is after the program's end time
                
                NSLog(@"** SEMA2API - proposed delivery time (%@) is after program's end time (%@)", [SEMA2API timestampToDateString:proposedDeliveryTimestamp], [SEMA2API timestampToDateString:programEndMillis]);
                
                int daysToIncrement = [self getDaysUntilNextAllowedDay:weekday forSurvey:survey];
                if (daysToIncrement != -1) {
                    
                    NSLog(@"** SEMA2API - attempting to reschedule %d days later", daysToIncrement);
                    
                    // set the delivery time to the next allowed day's start time (plus positive randomisation only)
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                    [offsetComponents setDay:daysToIncrement];
                    NSDate *nextAllowedDate = [gregorian dateByAddingComponents:offsetComponents toDate:startAtDateTime options:0];
                    
                    validDeliveryTimestamp = [SEMA2API dateToTimestamp:nextAllowedDate];
                }
                else {
                    validDeliveryTimestamp = -1;
                }
                
            }
            else { // the proposed time is within the valid start and end times
                
                NSLog(@"** SEMA2API - proposed delivery time (%@) is within programs start time (%@) and end time (%@)", [SEMA2API timestampToDateString:proposedDeliveryTimestamp], [SEMA2API timestampToDateString:programStartMillis], [SEMA2API timestampToDateString:programEndMillis]);
                
                validDeliveryTimestamp = proposedDeliveryTimestamp;
                
            }
        }
        else { // the day is not an 'allowed day'
            
            NSLog(@"** SEMA2API - the proposed day is not an allowed day");
            
            NSDate *proposedDate = [SEMA2API timestampToDate:proposedDeliveryTimestamp];
            NSDate *startOfDay = [proposedDate beginningOfDay];
            
            long scheduleStartAtSeconds = (survey.scheduleStartSendingAtHour * 60 * 60) + (survey.scheduleStartSendingAtMinute * 60);
            NSDate *startAtDateTime = [startOfDay dateByAddingTimeInterval:scheduleStartAtSeconds];
            long long programStartMillis = [SEMA2API dateToTimestamp:startAtDateTime];
            
            int daysToIncrement = [self getDaysUntilNextAllowedDay:weekday forSurvey:survey];
            if (daysToIncrement != -1) {
                
                NSLog(@"** SEMA2API - attempting to reschedule %d days later", daysToIncrement);
                
                // set the delivery time to the next allowed day's start time (plus positive randomisation only)
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setDay:daysToIncrement];
                NSDate *nextAllowedDate = [gregorian dateByAddingComponents:offsetComponents toDate:startAtDateTime options:0];
                
                validDeliveryTimestamp = [SEMA2API dateToTimestamp:nextAllowedDate];
            }
            else {
                validDeliveryTimestamp = -1;
            }
        }
        
        NSLog(@"** SEMA2API - valid delivery time is (%@)", [SEMA2API timestampToDateString:validDeliveryTimestamp]);

        set.deliveryTimestamp = validDeliveryTimestamp;
        
        set.expiryTimestamp = [SEMA2API addMinutes:survey.scheduleExpiryMinutes toTimestamp:validDeliveryTimestamp];
        set.timezone = tzName;
        
        // Increment the iteration count
        survey.currentIteration = survey.currentIteration + 1;
        
        [realm addObject:set];
    }
    else if (survey.answerTriggerMode == AnswerSetTriggerModeAdHoc) {
        
        set = [self createAnswerSetForSurvey:survey program:program realm:realm];
        
        set.deliveryTimestamp = baseTimestamp;
        
        // Increment the iteration count
        survey.currentIteration = survey.currentIteration + 1;
        
        [realm addObject:set];
    }
    
    return set;
}

- (AnswerSet*)createAnswerSetForSurvey:(Survey*)survey program:(Program*)program realm:(RLMRealm*)realm {
    
    // Setup the Answer Set
    AnswerSet *answerSet = [[AnswerSet alloc] init];
    
    answerSet.survey = survey;
    
    answerSet.dbProgramId = program.dbProgramId;
    answerSet.dbProgramVersionId = program.dbVersionId;
    answerSet.iteration = survey.currentIteration;
    answerSet.uuid = [SEMA2API genUUID];
    answerSet.dbSurveyId = survey.dbSurveyId;
    answerSet.answerTriggerMode = survey.answerTriggerMode;
    answerSet.createdTimestamp = -1;
    answerSet.deliveryTimestamp = -1;
    answerSet.expiryTimestamp = -1;
    answerSet.completedTimestamp = -1;
    answerSet.uploadedTimestamp = -1;
    answerSet.timezone = @"Australia/Melbourne";
    
    long long timestamp = [SEMA2API currentTimestamp];
    
    answerSet.createdTimestamp = timestamp;
    
    // Get the answer set's ordered question list (empty)
    RLMArray<Question> *orderedQuestionList = answerSet.orderedQuestions;
    
    // Get the list of question sets within the survey
    RLMArray<QuestionSet> *questionSets = survey.questionSets;
        
    // Iterate through the ordered question sets
    for (QuestionSet *questionSet in questionSets) {
        
        // Get the ist of questions within the question set
        RLMArray<Question> *questions = questionSet.questions;
        
        NSMutableArray *tmp = [NSMutableArray array];
        
        // Iterate through the ordered questions
        for (Question *question in questions) {
            
            // Add the question to the ordered questions list
            [tmp addObject:question];
        }
        
        if (questionSet.randomiseDisplayOrder) {
            [self shuffle:tmp];
        }
        
        [orderedQuestionList addObjects:tmp];
    }
    
    // Add the question to the ordered questions listanswer set's ordered questions list
    answerSet.orderedQuestions = orderedQuestionList;
    
    return answerSet;
}

- (void)shuffle:(NSMutableArray*)arr
{
    NSUInteger count = [arr count];
    
    for (NSUInteger i = 0; i < count; ++i) {
        
        // Select a random element between i and end of array to swap with.
        NSUInteger nElements = count - i;
        int n = arc4random_uniform(nElements) + i;
        [arr exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

- (void)createNotificationOrReminder:(AnswerSet*)set fireTime:(NSDate*)date isReminder:(BOOL)isReminder {
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    
    localNotif.fireDate = date;
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneWithName:@"Australia/Melbourne"]];
    [df setDateFormat:@"dd/MM/yyyy HH:mm:ss zzz"];
    NSLog(@"%@ - %@", [df stringFromDate:localNotif.fireDate], set.uuid);
    
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    NSString *message = isReminder ? [NSString stringWithFormat:@"%@ - Survey reminder.", set.survey.program.displayName] : [NSString stringWithFormat:@"%@ - A new survey is available.", set.survey.program.displayName];
    
    localNotif.alertBody = message;
    
    localNotif.alertAction = NSLocalizedString(@"View", nil);
    
    localNotif.soundName = @"alert.caf";
    localNotif.applicationIconBadgeNumber = 1;
    
    NSDictionary *infoDict = @{@"answerSetUUID": set.uuid};
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification: localNotif];
}

- (void)logLocalDate:(NSDate*)date {
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneWithName:@"Australia/Melbourne"]];
    [df setDateFormat:@"dd/MM/yyyy HH:mm:ss zzz"];
    NSLog(@"%@", [df stringFromDate:date]);
    
}

- (void)createNotificationForAnswerSet:(AnswerSet*)set {
    
    NSDate *fireTime = [NSDate dateWithTimeIntervalSince1970:set.deliveryTimestamp/1000.0];
    NSTimeInterval interval = ((set.expiryTimestamp - set.deliveryTimestamp) / 1000) / 3;
    //NSTimeInterval interval = (set.survey.scheduleIntervalMinutes * 60) / 3;
    
    // Initial message
    [self createNotificationOrReminder:set fireTime:fireTime isReminder:NO];
    
    // Reminder 1
    fireTime = [fireTime dateByAddingTimeInterval:interval];
    [self createNotificationOrReminder:set fireTime:fireTime isReminder:YES];
    
    // Reminder 2
    fireTime = [fireTime dateByAddingTimeInterval:interval];
    [self createNotificationOrReminder:set fireTime:fireTime isReminder:YES];
    //

}

- (void)clearExistingQuestionData:(Program*)program realm:(RLMRealm*)realm {
    
    for (Survey *survey in program.surveys) {
        
        for (QuestionSet *set in survey.questionSets) {
            
            for (Question *question in set.questions) {
                [realm deleteObjects:question.choices];
            }
            
            [realm deleteObjects:set.questions];
        }
        
        [realm deleteObjects:survey.questionSets];
    }
    
    [realm deleteObjects:program.surveys];
}

+ (void)showErrorWithTitle:(NSString*)title andMessage:(NSString*)message {
    
    [UIAlertView showWithTitle:title message:message cancelButtonTitle:@"Close" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
    }];
}


+ (id)parsePossiblyNullValue:(id)value {
    
    if (value == [NSNull null]) {
        return nil;
    }
    
    return value;
}

+ (id)safePossiblyNullValue:(id)value default:(id)defaultValue {
    
    if (value == [NSNull null] || value == nil)  {
        return defaultValue;
    }
    
    return value;
}

- (id)parseDateTime:(NSString*)value {
    
    return [NSDate sam_dateFromISO8601String:value];
}

+ (NSString *)genUUID {
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

+ (long long)currentTimestamp {
    return floor([[NSDate date] timeIntervalSince1970] * 1000);
}

+ (long long)dateToTimestamp:(NSDate*)date {
    return floor([date timeIntervalSince1970] * 1000);
}

+ (NSDate*)timestampToDate:(long long)ts {
    return [NSDate dateWithTimeIntervalSince1970:(ts / 1000)];
}

+ (long long)addMinutes:(NSInteger)minutes toTimestamp:(long long)ts {
    return ts + (minutes * 60.0 * 1000.0);
}

+ (long long)addDays:(NSInteger)days toTimestamp:(long long)ts {
    return ts + (days * 24 * 60 * 60 * 1000);
}

- (int)getDayFromTimestamp:(long long)timestamp {
    NSDate *date = [SEMA2API timestampToDate:timestamp];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
    int weekday = [comps weekday];
    return weekday;
}

+ (NSString*)wordedTimeSinceTimestamp:(long long)ts {
    
    if (ts == 0) {
        return @"";
    }
    
    long long minutesSinceTimestamp = [self minutesSinceTimestamp:ts];
    
    NSString *string;
    if (minutesSinceTimestamp == 0) {
        string = @"moments ago";
    }
    else if (minutesSinceTimestamp == 1) {
        string = [NSString stringWithFormat:@"1 minute ago"];
    }
    else if (minutesSinceTimestamp <= 10) {
        string = [NSString stringWithFormat:@"%lld minutes ago", minutesSinceTimestamp];
    }
    else {
        
        // TODO: extract day so that we can determine how many days it has been since last sync
        
        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        [df setTimeZone:[NSTimeZone timeZoneWithName:@"Australia/Melbourne"]];
        [df setDateFormat:@"hh:mm a"];
        NSString *time = [df stringFromDate:[SEMA2API timestampToDate:ts]];
        [df setDateFormat:@"MMM dd"];
        NSString *date = [df stringFromDate:[SEMA2API timestampToDate:ts]];
        string = [NSString stringWithFormat:@"at %@ on %@", time, date];
    }
    
    return string;
}

+ (long long)minutesSinceTimestamp:(long long)ts {
    long long seconds = ([SEMA2API currentTimestamp] - ts) / 1000;
    long long minutes = floor(seconds / 60.0);
    return minutes;
}

+ (NSString*)timestampToDateString:(long long)ts {
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneWithName:@"Australia/Melbourne"]];
    [df setDateFormat:@"dd/MM/yyyy HH:mm:ss zzz"];
    return [df stringFromDate:[SEMA2API timestampToDate:ts]];
}

- (BOOL)isAllowedDay:(int)weekday forSurvey:(Survey*)survey {
    
    if (weekday == 1) {
        return survey.scheduleAllowSunday;
    } else if (weekday == 2) {
        return survey.scheduleAllowMonday;
    } else if (weekday == 3) {
        return survey.scheduleAllowTuesday;
    } else if (weekday == 4) {
        return survey.scheduleAllowWednesday;
    } else if (weekday == 5) {
        return survey.scheduleAllowThursday;
    } else if (weekday == 6) {
        return survey.scheduleAllowFriday;
    } else if (weekday == 7) {
            return survey.scheduleAllowSaturday;
    } else {
        return false;
    }
    
}

- (void)cancelNotificationsForAnswerSet:(NSString*)answerSetUUID
{
    NSLog(@"**** cancelNotificationsForAnswerSet - searching for notifications for AnswerSet UUID %@", answerSetUUID);
    
    NSMutableArray * notificationsToCancel = [[NSMutableArray alloc] init];
    
    NSArray *scheduled = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSInteger count = [scheduled count];
    
    for (int j=0; j < count; j++) {
        
        UILocalNotification *notif = [scheduled objectAtIndex:j];
        
        if([[notif.userInfo objectForKey:@"answerSetUUID"] isEqualToString:answerSetUUID]) {
            
            // add to cancellations list
            [notificationsToCancel addObject:notif];
        }
    }

    NSLog(@"**** cancelNotificationsForAnswerSet - cancelling %ld notifications", [notificationsToCancel count]);
    
    // cancel items in the list
    for (NSInteger i = ([notificationsToCancel count] - 1); i >= 0; i--) {
        [[UIApplication sharedApplication] cancelLocalNotification:[notificationsToCancel objectAtIndex:i]];
    }
}

- (int)getDaysUntilNextAllowedDay:(int)startDay forSurvey:(Survey*)survey {
    
    int nextWeekDay;
    for (int i = 1; i <= 7; i++) {
        nextWeekDay = ((startDay - 1 + i) % 7) + 1;
        if ([self isAllowedDay:nextWeekDay forSurvey:survey]) {
            return i;
        }
    }
    
    return -1;
}


@end

