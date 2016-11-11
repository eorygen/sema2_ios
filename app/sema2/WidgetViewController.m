//
//  WidgetViewController.m
//  sema2
//
//  Created by Starehe Harrison on 17/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "WidgetViewController.h"
#import "SEMA2API.h"
#import "markdown_peg.h"

@interface WidgetViewController ()

@end

@implementation WidgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set displayed timestamp
    self.displayedTimestamp = [SEMA2API currentTimestamp];
    self.startHRTimestamp = [[SEMA2API sharedClient] getHiresTimestamp];
    
    // create a font attribute for emphasized text
    self.boldFont = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
    self.emFont = [UIFont fontWithName:@"Helvetica-Oblique" size:17.0];
    
    // create a dictionary to hold your custom attributes for any Markdown types
    self.attribs = @{
                                 @(STRONG): @{NSFontAttributeName : self.boldFont},
                                 @(EMPH): @{NSFontAttributeName : self.emFont},
                                 };
    
}

- (void)incrementQuestionIndex {
    self.answerSet.currentQuestionIndex++;
    if (self.answerSet.currentQuestionIndex >= [self.answerSet.orderedQuestions count]) {
        self.answerSet.currentQuestionIndex = -1; // survey completed
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveQuestionToDB {
    self.answeredTimestamp = [SEMA2API currentTimestamp];
    long long endHRTimestamp = [[SEMA2API sharedClient] getHiresTimestamp];
    self.reactionTimeMs = endHRTimestamp - self.startHRTimestamp;
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
