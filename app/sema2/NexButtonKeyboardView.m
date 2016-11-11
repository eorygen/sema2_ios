//
//  NexButtonKeyboardView.m
//  sema2
//
//  Created by Ashemah Harrison on 17/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "NexButtonKeyboardView.h"

@implementation NexButtonKeyboardView

- (void)awakeFromNib {
    self.nextButton.buttonColor = [UIColor peterRiverColor];
    self.nextButton.shadowColor = [UIColor belizeHoleColor];
    self.nextButton.shadowHeight = 3.0f;
    self.nextButton.cornerRadius = 6.0f;
    self.nextButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.nextButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
