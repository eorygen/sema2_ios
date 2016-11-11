//
//  BHUplinkManager.m
//  safe_d
//
//  Created by Ashemah Harrison on 21/11/2014.
//  Copyright (c) 2014 Ashemah Harrison. All rights reserved.
//

#import "BHUplinkManager.h"
#import "FeedbackVC.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIAlertView+Blocks.h"

@implementation BHUplinkManager

- (instancetype)initWithServerURL:(NSString*)serverURL andName:(NSString*)name1 {
    
    self = [super init];
    if (self) {
        self.uplinkServerURL = serverURL;
        self.name = name1;
    }
    return self;
}

- (void)checkForUpdates:(BOOL)force {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSDate *lastCheck = [prefs objectForKey:kUplinkUpdateLastCheckedDate];
    NSDate *curDate = [NSDate date];
    
    if (force || !lastCheck || [curDate timeIntervalSinceDate:lastCheck] > kUplinkUpdateCheckIntervalHours * 60 * 60) {
     
        [self performSelector:@selector(getUpdateInfo) withObject:nil afterDelay:2];
        
        [prefs setObject:curDate forKey:kUplinkUpdateLastCheckedDate];
        [prefs synchronize];
    }
}

- (void)getUpdateInfo {
    
    NSString *platformId = @"ios";
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];

    NSDictionary *params = @{
                             @"platform_id": platformId,
                             @"build_number": buildNumber
                             };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [[AFJSONRequestSerializer alloc] init];
    manager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
    
    [manager POST:[NSString stringWithFormat:@"%@update/", self.uplinkServerURL] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        if ([responseObject[@"update_is_available"] boolValue] == YES) {
                        
            [UIAlertView showWithTitle:@"Update Available" message:[NSString stringWithFormat:@"An update is available for %@.\n\nPlease tap 'Update Now' to install it", self.name] cancelButtonTitle:@"Later" otherButtonTitles:@[@"Update Now"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    NSURL *url = [NSURL URLWithString:responseObject[@"update_url"]];
                    [[UIApplication sharedApplication] openURL:url];
                }
            }];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
}

- (void)launchFeedback:(UIViewController*)parent1 {

    self.parent = parent1;
    
    if ([MFMailComposeViewController canSendMail]){
        
        // Email Subject
        NSString *emailTitle = [NSString stringWithFormat:@"%@: Feedback/Question", self.name];
        
        // To address
        NSArray *toRecipents = [NSArray arrayWithObjects:@"randomised@safedstudy.org", @"ashemah@boostedhuman.com", nil];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:@"" isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self.parent presentViewController:mc animated:YES completion:^{
        }];
    }
    else {
        [UIAlertView showWithTitle:@"Please set up email on your phone" message:[NSString stringWithFormat:@"%@ cannot send your feedback/question because email has not yet been set up on your device.", self.name] cancelButtonTitle:@"Close" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
        NSLog(@"Mail cancelled");
        break;
        
        case MFMailComposeResultSaved:
        NSLog(@"Mail saved");
        break;
        
        case MFMailComposeResultSent:
        NSLog(@"Mail sent");
        
        [UIAlertView showWithTitle:@"Mail Sent" message:@"Your mail was sent successfully" cancelButtonTitle:@"Close" otherButtonTitles:@[] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
        
        break;
        
        case MFMailComposeResultFailed:
        NSLog(@"Mail sent failure: %@", [error localizedDescription]);
        
        [UIAlertView showWithTitle:@"Error sending Mail" message:[NSString stringWithFormat:@"An error occurred while sending the mail: %@", [error localizedDescription]] cancelButtonTitle:@"Close" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
        
        break;
        
        default:
        break;
    }
    
    // Close the Mail Interface
    [self.parent dismissViewControllerAnimated:YES completion:^{
    }];
}

//    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"FeedbackVC" owner:nil options:nil];
//    
//    UINavigationController *nav = (UINavigationController*)[array objectAtIndex:0];
//    
//    FeedbackVC *vc = (FeedbackVC*)[nav topViewController];
//    vc.feedbackURL = [NSString stringWithFormat:@"%@/api/1/uplink/feedback/", self.uplinkServerURL];
//    [parent presentViewController:nav animated:YES completion:^{
//        
//    }];
//}

@end
