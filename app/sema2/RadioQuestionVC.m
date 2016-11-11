//
//  RadioQuestionVC.m
//  sema2
//
//  Created by Ashemah Harrison on 16/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "RadioQuestionVC.h"
#import "RadioButtonCell.h"
#import "SEMA2API.h"
#import "SurveyVC.h"
#import "NSArray+SAMAdditions.h"
#import "markdown_lib.h"

@implementation RadioQuestionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.set = [NSMutableSet set];
    self.items = [NSMutableArray array];
    
    for (QuestionChoice *choice in self.question.choices) {
        [self.items addObject:choice];
    }
    
    if (self.question.randomiseDisplayOrder) {
        [self.items sam_shuffle];
    }
    
    NSAttributedString *prettyText = markdown_to_attr_string(self.question.questionText, 0, self.attribs);
    self.questionText.attributedText = prettyText;
    // TODO: setup listview
    
    BHBlockTableWeakSelf weakSelf = self;
    
    self.blockTable = [[BHBlockTable alloc] initWithTableView:self.tableView];
    
    // Survey Section
    self.section = [self.blockTable dynamicSectionWithCellIdentifier:@"RadioButtonCell" headerViewClass:nil andVisibility:YES];
    
    self.section.configureCellForRow =^(BHBlockTableInfo *info) {
        
        RadioButtonCell *cell = info.cell;
        QuestionChoice *choice = weakSelf.items[info.row];
        
        NSAttributedString *prettyText = markdown_to_attr_string(choice.choiceText, 0, weakSelf.attribs);
        cell.label.attributedText = prettyText;
        
        NSNumber *choiceId = @(choice.dbChoiceId);
        if ([weakSelf.set member:choiceId]) {
            [cell.cb setAlpha:1];
        }
        else {
            [cell.cb setAlpha:0.2];
        }
    };
    
    self.section.numberOfRows =^NSInteger(BHBlockTableInfo *info) {
        return [weakSelf.items count];
    };
    
    self.section.didSelectRow =^void(BHBlockTableInfo *info) {
        
        QuestionChoice *choice = weakSelf.items[info.row];
        
        NSNumber *choiceId = @(choice.dbChoiceId);
        
        [weakSelf.set removeAllObjects];
        [weakSelf.set addObject:choiceId];
        
        // validate
        [weakSelf.delegate isValid:[weakSelf isValid]];
        
        info.refreshMode = BHBlockTableRefreshMode_Section;
    };
    
    [self.blockTable refresh];
}

- (BOOL)isValid {
    if ([self.set count] > 0) {
        return true;
    }
    else {
        return false;
    }
}

- (void)saveQuestionToDB {
    [super saveQuestionToDB];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    // get the checked item
    NSArray *checked = [self.set allObjects];
    NSNumber *choiceId = [checked objectAtIndex:0];

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
    answer.answerValue = [choiceId stringValue];

    // save the object to the realm and increment the current question index
    [realm addObject:answer];
    [self.answerSet.answers addObject:answer];
    
    [self incrementQuestionIndex];
    [realm commitWriteTransaction];
}

@end
