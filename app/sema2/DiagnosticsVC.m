//
//  DiagnosticsVC.m
//  sema2
//
//  Created by Ashemah Harrison on 22/10/2015.
//  Copyright © 2015 Starehe Harrison. All rights reserved.
//

#import "DiagnosticsVC.h"
#import "SEMA2API.h"
#import "UIAlertView+Blocks.h"

@interface DiagnosticsVC ()

@end

@implementation DiagnosticsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDidStart:) name:kSyncStateStarted object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDidComplete:) name:kSyncStateCompleted object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDidCompleteWithError:) name:kSyncStateError object:nil];    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    SEMA2API *api = [SEMA2API sharedClient];

    self.connectionStateLabel.text = api.isOnline ? @"Connected to the Internet" : @"Could not connect to the Internet";
    
    NSURL *URL = [NSURL URLWithString:@"https://sema-surveys.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.serverStateLabel.text = @"Connected to SEMA";
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.serverStateLabel.text = @"Could not connect to SEMA";
    }];
    
    [op start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)syncDidStart:(id)notification {
    [self.syncSpinner startAnimating];
    self.syncLabel.text = @"Synchronising...";
}

- (void)syncDidComplete:(id)notification {
    [self.syncSpinner stopAnimating];
    self.syncLabel.text = @"Sync completed OK.";
}

- (void)syncDidCompleteWithError:(id)notification {
    [self.syncSpinner stopAnimating];
    self.syncLabel.text = @"Sync error.";
}
- (IBAction)signOutTapped:(id)sender {
}

- (IBAction)forceSyncTapped:(id)sender {
    
    SEMA2API *api = [SEMA2API sharedClient];
    
    if (!api.isOnline) {
        
        [UIAlertView showWithTitle:@"Offline" message:@"Please go online to sync" cancelButtonTitle:@"Cancel" otherButtonTitles:nil tapBlock:nil];
    }
    else {
        
        // Force disab
        [api enableSync];
        api.isSynchronising = NO;
        
        [api runSync:YES];
    }
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
