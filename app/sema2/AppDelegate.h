//
//  AppDelegate.h
//  sema2
//
//  Created by Starehe Harrison on 14/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHUplinkManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) BHUplinkManager *uplink;
@property (assign, nonatomic) BOOL isResumingFromBackground;

- (void)playSound:(NSString *)sound;

@end

