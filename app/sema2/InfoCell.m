//
//  InfoCell.m
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "InfoCell.h"

@implementation InfoCell

- (void)awakeFromNib {
    // Initialization code
    
    self.callButton.buttonColor = [UIColor turquoiseColor];
    self.callButton.shadowColor = [UIColor greenSeaColor];
    self.callButton.shadowHeight = 3.0f;
    self.callButton.cornerRadius = 6.0f;
    self.callButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.callButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.callButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    self.callButton.enabled = YES;
    
    self.emailButton.buttonColor = [UIColor turquoiseColor];
    self.emailButton.shadowColor = [UIColor greenSeaColor];
    self.emailButton.shadowHeight = 3.0f;
    self.emailButton.cornerRadius = 6.0f;
    self.emailButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.emailButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.emailButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    self.emailButton.enabled = YES;

    self.demoButton.buttonColor = [UIColor turquoiseColor];
    self.demoButton.shadowColor = [UIColor greenSeaColor];
    self.demoButton.shadowHeight = 3.0f;
    self.demoButton.cornerRadius = 6.0f;
    self.demoButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.demoButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.demoButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    self.demoButton.enabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
