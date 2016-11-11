//
//  LoginViewController.h
//  sema2
//
//  Created by Starehe Harrison on 14/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FUITextField.h"
#import "FUIButton.h"
#import <FlatUIKit/UIColor+FlatUI.h>
#import "UIFont+FlatUI.h"
#import "NSString+Icons.h"

@protocol LoginDelegate <NSObject>
-(void)didSignInSuccessfully;
@end

@interface LoginVC : UIViewController

@property (weak, nonatomic) IBOutlet FUIButton *loginButton;
@property (weak, nonatomic) IBOutlet FUITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet FUITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (assign, nonatomic) id<LoginDelegate> delegate;

@end
