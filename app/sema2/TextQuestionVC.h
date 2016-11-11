//
//  TextQuestionVC.h
//  sema2
//
//  Created by Ashemah Harrison on 16/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WidgetViewController.h"
#import <FlatUIKit/FlatUIKit.h>
#import "NexButtonKeyboardView.h"

@interface TextQuestionVC : WidgetViewController<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *questionText;
@property (weak, nonatomic) IBOutlet UITextView *answerText;
@property (weak, nonatomic) IBOutlet NexButtonKeyboardView *kbView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrolling;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@end
