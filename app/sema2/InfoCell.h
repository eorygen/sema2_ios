//
//  InfoCell.h
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FUIButton.h"
#import <FlatUIKit/UIColor+FlatUI.h>
#import "UIFont+FlatUI.h"

@interface InfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *displayName;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet FUIButton *callButton;
@property (weak, nonatomic) IBOutlet FUIButton *emailButton;
@property (weak, nonatomic) IBOutlet FUIButton *demoButton;
@property (weak, nonatomic) IBOutlet UILabel *contactName;
@property (weak, nonatomic) IBOutlet UILabel *contactEmail;
@property (weak, nonatomic) IBOutlet UILabel *contactPhone;

@end
