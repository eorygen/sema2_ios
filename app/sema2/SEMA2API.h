//
//  SEMA2API.h
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AFHTTPRequestOperationManager.h"
#import "Program.h"

#define kSyncStateStarted @"kSyncStateStarted"
#define kSyncStateCompleted @"kSyncStateCompleted"
#define kSyncStateError @"kSyncStateError"

#define kLaunchSurvey @"kLaunchSurvey"
#define kRefreshDashboard @"kRefreshDashboard"

#define kSyncDataStartTimestamp @"kSyncDataStartTimestamp"
#define kSyncDataEndTimestamp @"kSyncDataEndTimestamp"
#define kSyncDataOffline @"kSyncDataSyncOffline"
#define kSyncDataServerTestFailed @"kSyncDataServerTestFailed"
#define kSyncDataCount @"kSyncDataCount"
#define kSyncDataSendCount @"kSyncDataSendCount"

#define kMaxScheduledAnswerSets 50 // max scheduled answer sets per survey at any one time
#define kMinScheduledAnswerSetThreshold 25 // answer sets will be replenished to the max if they fall below this value (if iterations permit)
#define kMaxScheduledAlerts 20 // 64 in total divided by 3


@interface SEMA2API : AFHTTPRequestOperationManager {
    
}

@property (retain, nonatomic) NSString *appVersion;
@property (retain, nonatomic) NSString *versionString;
@property (retain, nonatomic) NSString *buildNumber;
@property (assign, nonatomic) BOOL allowSync;
@property (assign, nonatomic) BOOL isOnline;

@property (retain, nonatomic) NSString *userName;
@property (retain, nonatomic) NSString *pushToken;
@property (retain, nonatomic) NSString *authToken;
@property (assign, nonatomic) BOOL isSynchronising;
@property (assign, nonatomic) NSString *launchedAnswerSetUUID;
@property (assign, nonatomic) BOOL didResumeFromBackground;

@property (retain, nonatomic) NSString *deviceToken;
@property (retain, nonatomic) NSString *timezone;

+ (SEMA2API *)sharedClient;
- (BOOL)hasValidAuthToken;
- (id)initWithBaseURL:(NSURL *)url;
+ (void)hideSpinner;
+ (void)showSpinner:(NSString*)msg;
+ (id)parsePossiblyNullValue:(id)value;
+ (id)safePossiblyNullValue:(id)value default:(id)defaultValue;
+ (void)showErrorWithTitle:(NSString*)title andMessage:(NSString*)message;
+ (NSString *)genUUID;
+ (long long)currentTimestamp;
- (void)handleNormalLaunch;
- (void)handleRemoteNotification:(NSDictionary*)notif;
- (void)handleNotification:(UILocalNotification*)notif;
- (void)storeDeviceToken:(NSData*)token;
- (NSString*)calcStatus:(Program*)program;
- (void)signOut;
- (void)cancelNotificationsForAnswerSet:(NSString*)answerSetUUID;

- (long long)getHiresTimestamp;

- (void)disableSync;
- (void)enableSync;
+ (long long)addMinutes:(NSInteger)minutes toTimestamp:(long long)ts;
+ (NSString*)timestampToDateString:(long long)ts;
+ (NSString*)wordedTimeSinceTimestamp:(long long)ts;

- (id)doSynchronousPOST:(NSString*)url params:(id)params error:(NSInteger*)errorCode;

- (void)authenticateWithUsername:(NSString*)username password:(NSString*)password didSucceed:(void(^)())didSucceed didFail:(void(^)(NSString *errorMessage))didFail;

- (void)resetPasswordForUsername:(NSString*)email didSucceed:(void(^)())didSucceed didFail:(void(^)(NSString *errorMessage))didFail;

- (void)runSync;
- (void)runSync:(BOOL)forceUpload;
@end