//
//  TextQuestionVC.m
//  sema2
//
//  Created by Ashemah Harrison on 16/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "TextQuestionVC.h"
#import "SEMA2API.h"
#import "SurveyVC.h"
#import "markdown_lib.h"

@implementation TextQuestionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAttributedString *prettyText = markdown_to_attr_string(self.question.questionText, 0, self.attribs);
    self.questionText.attributedText = prettyText;
    
    self.kbView = [[[NSBundle mainBundle] loadNibNamed:@"NextButtonKeyboardView" owner:self options:nil] objectAtIndex:0];
    [self.kbView.nextButton addTarget:self action:@selector(nextTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.answerText.inputAccessoryView = self.kbView;
    
    self.answerText.delegate = self;
    [self.answerText becomeFirstResponder];
    
    [self.answerText setScrollEnabled:NO];
    
    self.scrolling.contentSize = self.contentView.bounds.size;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.delegate isValid:[self isValid]];
}

- (BOOL)isValid {
    if ([self.answerText.text length] > 0) { // TODO: shouldn't take whitespace into consideration for this calc
        return true;
    }
    else {
        return false;
    }
}

- (IBAction)nextTapped:(id)sender {
    [self.answerText resignFirstResponder];
}

- (void)saveQuestionToDB {
    [super saveQuestionToDB];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    // create a new answer
    Answer *answer = [[Answer alloc] init];
    answer.answerSet = self.answerSet;
    answer.dbSurveyId = self.dbSurveyId;
    answer.dbQuestionSetId = self.dbQuestionSetId;
    answer.dbQuestionId = self.dbQuestionId;
    answer.reactionTimeMs = self.reactionTimeMs;
    
    // set the answer value
    answer.answerValue = self.answerText.text;
    
    // timestamp
    answer.answeredTimestamp = self.answeredTimestamp;
    answer.displayedTimestamp = self.displayedTimestamp;
    
    // save the object to the realm and increment the current question index
    [realm addObject:answer];
    [self.answerSet.answers addObject:answer];
    [self incrementQuestionIndex];
    [realm commitWriteTransaction];
}

@end
