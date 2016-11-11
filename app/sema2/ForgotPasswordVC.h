//
//  ForgotPasswordVC.h
//  sema2
//
//  Created by Ashemah Harrison on 24/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlatUIKit.h"

@interface ForgotPasswordVC : UIViewController
@property (weak, nonatomic) IBOutlet FUITextField *emailAddress;
@property (weak, nonatomic) IBOutlet FUIButton *resetButton;

@end
