//
//  SliderQuestionVC.h
//  sema2
//
//  Created by Ashemah Harrison on 16/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WidgetViewController.h"
#import "ASValueTrackingSlider.h"

@interface SliderQuestionVC : WidgetViewController<ASValueTrackingSliderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *questionText;
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *minValueText;
@property (weak, nonatomic) IBOutlet UILabel *maxValueText;
@property (weak, nonatomic) IBOutlet UILabel *minLabelText;
@property (weak, nonatomic) IBOutlet UILabel *maxLabelText;

@end
