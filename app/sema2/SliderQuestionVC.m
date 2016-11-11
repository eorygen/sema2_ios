//
//  SliderQuestionVC.m
//  sema2
//
//  Created by Ashemah Harrison on 16/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "SliderQuestionVC.h"
#import "SEMA2API.h"
#import "markdown_peg.h"
#import "UIColor+FlatUI.h"

@implementation SliderQuestionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAttributedString *prettyText = markdown_to_attr_string(self.question.questionText, 0, self.attribs);
    self.questionText.attributedText = prettyText;
    
    self.slider.minimumValue = self.question.minimumValue;
    self.slider.maximumValue = self.question.maximumValue;
    self.slider.value = self.question.minimumValue + ((self.question.maximumValue - self.question.minimumValue) * 0.5);
    [self.slider setMaxFractionDigitsDisplayed:0];
    [self.slider setPopUpViewWidthPaddingFactor:2];
    [self.slider setPopUpViewColor:[UIColor turquoiseColor]];
    self.slider.delegate = self;

    self.minValueText.text = [NSString stringWithFormat:@"%ld", (long)self.question.minimumValue];
    self.maxValueText.text =  [NSString stringWithFormat:@"%ld", (long)self.question.maximumValue];
    
    NSString *tmp = [NSString stringWithFormat:@"%ld = %@", (long)self.question.minimumValue, self.question.minimumLabel];
    NSAttributedString *minValueLabel = markdown_to_attr_string(tmp, 0, self.attribs);
    self.minLabelText.attributedText = minValueLabel;

    tmp = [NSString stringWithFormat:@"%ld = %@", (long)self.question.maximumValue, self.question.maximumLabel];
    NSAttributedString *maxValueLabel = markdown_to_attr_string(tmp, 0, self.attribs);
    self.maxLabelText.attributedText = maxValueLabel;
    
    [self.slider addTarget:self action:@selector(changeSlider:) forControlEvents:UIControlEventValueChanged];
}

- (void)sliderWillDisplayPopUpView:(ASValueTrackingSlider *)slider {
    
}

- (void)sliderDidHidePopUpView:(ASValueTrackingSlider *)slider {
}

-(void)changeSlider:(id)sender{
    self.slider.value = lroundf(self.slider.value);
    [self.delegate isValid:true];
    [self.slider showPopUpViewAnimated:NO];
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
    answer.displayedTimestamp = self.displayedTimestamp;
    answer.answeredTimestamp = self.answeredTimestamp;
    answer.reactionTimeMs = self.reactionTimeMs;
    
    // set the answer value
    answer.answerValue = [NSString stringWithFormat:@"%d", (int)self.slider.value];
    
    // save the object to the realm and increment the current question index
    [realm addObject:answer];
    [self.answerSet.answers addObject:answer];
    
    [self incrementQuestionIndex];
    [realm commitWriteTransaction];
}

@end
