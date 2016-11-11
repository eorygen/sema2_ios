//
//  BasicHeader.h
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicHeader : UIView

- (void)setTitle:(NSString*)title;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
