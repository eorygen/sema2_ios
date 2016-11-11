//
//  FeedbackVC.m
//  safe_d
//
//  Created by Ashemah Harrison on 21/11/2014.
//  Copyright (c) 2014 Ashemah Harrison. All rights reserved.
//

#import "FeedbackVC.h"
#import "AFHTTPRequestOperationManager.h"

@interface FeedbackVC ()

@end

@implementation FeedbackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)sendTapped:(id)sender {
    
    NSDictionary *params = @{
                             @"content": self.content.text
                             };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [[AFJSONRequestSerializer alloc] init];
    manager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
    
    [manager POST:self.feedbackURL parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
