//
//  DiagnosticsVC.h
//  sema2
//
//  Created by Ashemah Harrison on 22/10/2015.
//  Copyright © 2015 Starehe Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiagnosticsVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *connectionStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *syncLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *syncSpinner;

@end
