//
//  BHPulseValue.h
//  safe_d
//
//  Created by Ashemah Harrison on 2/14/14.
//  Copyright (c) 2014 Ashemah Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHPulseDefines.h"

@interface BHPulseValue : NSObject<UITextFieldDelegate, UITextViewDelegate>

@property (retain, nonatomic) BHPulseContext *context;
@property (nonatomic, weak) id uiField;
@property (nonatomic, retain) NSMutableSet *dependents;

@property (nonatomic, copy) NSString *key;
@property (copy, nonatomic) NSString *placeholder;
@property (nonatomic, copy) id value;

@property (assign, nonatomic) BOOL isValid;
@property (assign, nonatomic) BOOL isRequired;
@property (assign, nonatomic) BOOL isLastValue;
@property (assign, nonatomic) BOOL showDoneButton;

@property (readwrite, copy) ValidateValueBlock validateValueBlock;
@property (copy, nonatomic) TextFieldShouldReturn textFieldShouldReturn;
@property (assign, nonatomic) BHPulseValueType type;
@property (retain, nonatomic) BHPulseValue *nextValue;

- (BOOL)validateValue:(id)value;
- (NSString*)stringValue;
- (void)setUIElement:(id)uiElement andType:(BHPulseValueType)type;

@end
