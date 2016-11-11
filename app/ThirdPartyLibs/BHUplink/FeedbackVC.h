//
//  FeedbackVC.h
//  safe_d
//
//  Created by Ashemah Harrison on 21/11/2014.
//  Copyright (c) 2014 Ashemah Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackVC : UIViewController<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *content;
@property (retain, nonatomic) NSString *feedbackURL;
@end
