//
//  BHUplinkManager.h
//  safe_d
//
//  Created by Ashemah Harrison on 21/11/2014.
//  Copyright (c) 2014 Ashemah Harrison. All rights reserved.
//

#define kUplinkUpdateLastCheckedDate @"kUplinkUpdateLastCheckedDate"
#define kUplinkUpdateCheckIntervalHours 6

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h> 

@interface BHUplinkManager : NSObject<MFMailComposeViewControllerDelegate>

@property (retain, nonatomic) NSString *uplinkServerURL;
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) UIViewController *parent;

- (instancetype)initWithServerURL:(NSString*)serverURL andName:(NSString*)name1;
- (void)checkForUpdates:(BOOL)force;
- (void)launchFeedback:(UIViewController*)parent;

@end
