//
//  AppDelegate.m
//  sema2
//
//  Created by Starehe Harrison on 14/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkActivityLogger.h"
#import "SEMA2API.h"
#import <Realm/Realm.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [AFNetworkActivityLogger sharedLogger].level = AFLoggerLevelDebug;

    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 4;
    
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        
        if (oldSchemaVersion < 1) {
            
        }
        else if (oldSchemaVersion == 1) {
            
        }
        else if (oldSchemaVersion == 2) {
            
        }
        else if (oldSchemaVersion == 3) {
            
        }
    };

    [RLMRealmConfiguration setDefaultConfiguration:config];
    [RLMRealm defaultRealm];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    [realm commitWriteTransaction];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (localNotif) {
        [[SEMA2API sharedClient] handleNotification:localNotif];
    }
    else if (remoteNotif) {
        [[SEMA2API sharedClient] handleRemoteNotification:remoteNotif];
    }
    else {
        [[SEMA2API sharedClient] handleNormalLaunch];
    }
    
    self.uplink = [[BHUplinkManager alloc] initWithServerURL:@"https://sema-surveys.com/api/1/uplink/" andName:@"SEMA"];
    
    [Crashlytics startWithAPIKey:@"daf49d8abfeceb9f13929b8077f286d7fed85194"];
    
    return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    [[SEMA2API sharedClient] storeDeviceToken:devToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)playSound:(NSString *)sound {
    
    if (sound) {
        
        // Note: The default sound is not available in the app.
        //
        // From http://developer.apple.com/library/ios/#documentation/AudioToolbox/Reference/SystemSoundServicesReference/Reference/reference.html :
        // System-supplied alert sounds and system-supplied user-interface sound effects are not available to your iOS application.
        // For example, using the kSystemSoundID_UserPreferredAlert constant as a parameter to the AudioServicesPlayAlertSound
        // function will not play anything.
        
        SystemSoundID soundID;
        NSString *path = [[NSBundle mainBundle] pathForResource:[sound stringByDeletingPathExtension]
                                                         ofType:[sound pathExtension]];
        if (path) {
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
            AudioServicesPlayAlertSound(soundID);
        } else {
        }
        
    } else {
        
        // Vibrates on supported devices, on others, does nothing
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [[SEMA2API sharedClient] handleRemoteNotification:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[SEMA2API sharedClient] handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    [self playSound:nil];
    [[SEMA2API sharedClient] handleNotification:notif];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [SEMA2API sharedClient].didResumeFromBackground = YES;    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if ([SEMA2API sharedClient].isOnline) {
        [self performSelector:@selector(performSync) withObject:nil afterDelay:2];
    }
}

- (void)performSync {
    [[SEMA2API sharedClient] runSync];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
