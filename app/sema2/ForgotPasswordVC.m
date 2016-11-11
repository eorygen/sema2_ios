//
//  ForgotPasswordVC.m
//  sema2
//
//  Created by Ashemah Harrison on 24/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "ForgotPasswordVC.h"
#import "SEMA2API.h"
#import "UIAlertView+Blocks.h"

@interface ForgotPasswordVC ()

@end

@implementation ForgotPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.resetButton.buttonColor = [UIColor turquoiseColor];
    self.resetButton.shadowColor = [UIColor greenSeaColor];
    self.resetButton.shadowHeight = 3.0f;
    self.resetButton.cornerRadius = 6.0f;
    self.resetButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.resetButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.resetButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resetTapped:(id)sender {
    
    self.resetButton.enabled = NO;
    
    [[SEMA2API sharedClient] resetPasswordForUsername:self.emailAddress.text didSucceed:^{

        self.resetButton.enabled = YES;
        
        [UIAlertView showWithTitle:@"Success" message:@"Please check your email account (including spam folders) for a reminder of your Participant ID and information on how to reset your password if required." cancelButtonTitle:@"Close" otherButtonTitles:nil tapBlock:nil];
        
        [self performSegueWithIdentifier:@"ReminderSent" sender:self];
        
    } didFail:^(NSString *errorMessage) {
        
        self.resetButton.enabled = YES;
        
        [UIAlertView showWithTitle:@"Error" message:errorMessage cancelButtonTitle:@"Close" otherButtonTitles:nil tapBlock:nil];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
