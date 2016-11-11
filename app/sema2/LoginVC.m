//
//  LoginViewController.m
//  sema2
//
//  Created by Starehe Harrison on 14/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "LoginVC.h"
#import "SEMA2API.h"
#import "DashboardVC.h"

@interface LoginVC ()

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.loginButton.buttonColor = [UIColor turquoiseColor];
    self.loginButton.shadowColor = [UIColor greenSeaColor];
    self.loginButton.shadowHeight = 3.0f;
    self.loginButton.cornerRadius = 6.0f;
    self.loginButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.loginButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.usernameTextField.text = [prefs objectForKey:@"username"];
    
    if ([self.usernameTextField.text length] == 0) {
        [self.usernameTextField becomeFirstResponder];
    }
    
    NSString *versionString = [NSString stringWithFormat:@"v%@(%@)", [[SEMA2API sharedClient] versionString], [[SEMA2API sharedClient] buildNumber]];
    
    self.versionLabel.text = versionString;
}

- (IBAction)handleUnwindToLogin:(UIStoryboardSegue*)segue {
    
}

- (IBAction)signInTapped:(id)sender {
    
    self.loginButton.enabled = NO;
    
    [[SEMA2API sharedClient] authenticateWithUsername:self.usernameTextField.text password:self.passwordTextField.text didSucceed:^{
    
        self.loginButton.enabled = YES;
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:self.usernameTextField.text forKey:@"username"];
        [prefs synchronize];
        
        [self performSegueWithIdentifier:@"SignedIn" sender:self];
        
    } didFail:^(NSString *errorMessage) {

        self.loginButton.enabled = YES;
        [SEMA2API showErrorWithTitle:@"Error" andMessage:errorMessage];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

@end
