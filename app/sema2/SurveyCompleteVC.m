//
//  SurveyCompleteVC.m
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "SurveyCompleteVC.h"
#import "SEMA2API.h"
#import "SVProgressHUD.h"

@interface SurveyCompleteVC ()

@end

@implementation SurveyCompleteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.navigationItem.hidesBackButton = YES;
    
    self.doneButton.buttonColor = [UIColor turquoiseColor];
    self.doneButton.shadowColor = [UIColor greenSeaColor];
    self.doneButton.shadowHeight = 3.0f;
    self.doneButton.cornerRadius = 6.0f;
    self.doneButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.doneButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backTapped:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeBlack];
    [self performSelector:@selector(goToDashboard) withObject:nil afterDelay:5];
    [[SEMA2API sharedClient] runSync];
}

- (void)goToDashboard {
    [SVProgressHUD dismiss];
    [self performSegueWithIdentifier:@"Dashboard" sender:self];
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
