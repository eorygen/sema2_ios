//
//  BHPulseValue.m
//  safe_d
//
//  Created by Ashemah Harrison on 2/14/14.
//  Copyright (c) 2014 Ashemah Harrison. All rights reserved.
//

#import "BHPulseValue.h"
#import "BHPulseContext.h"

@implementation BHPulseValue

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    
}

- (NSString*)stringValue {

    if ([self.value isKindOfClass:[NSNumber class]]) {
        return [self.value stringValue];
    }
    else {
        return self.value;
    }
    
}

- (void)textViewDidChange:(UITextView *)textView {
    self.value = textView.text;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([self showPlaceholder]) {
        textView.text = @"";
    }
    else {
        textView.text = self.value;
    }
    
    if (self.showDoneButton) {
        [self addDoneButton:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([self showPlaceholder]) {
        textView.text = self.placeholder;
    }
    else {
        textView.text = self.value;
    }
}

-(void)fieldTextChanged:(id)sender {
    self.value = ((UITextField*)sender).text;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.textFieldShouldReturn) {
        return self.textFieldShouldReturn(self);
    }
    
    return [self.context notifyTextFieldShouldReturn:self];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (self.isLastValue) {
        textField.returnKeyType = UIReturnKeyDone;
    }
    else {
        textField.returnKeyType = UIReturnKeyNext;
    }
    
    if (self.showDoneButton) {
        [self addDoneButton:self];
    }    
}

- (BOOL)showPlaceholder {
    return !self.value || [self.value length] == 0;
}

- (void)setUIElement:(id)uiElement andType:(BHPulseValueType)type {
    
    if ([uiElement isKindOfClass:[UITextField class]]) {
        UITextField *tf = (UITextField*)uiElement;
        tf.delegate = self;
        tf.placeholder = self.placeholder;
        [tf addTarget:self action:@selector(fieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
        
        self.showDoneButton = YES;
        
    }
    else if ([uiElement isKindOfClass:[UITextView class]]) {
        UITextView *tv = (UITextView*)uiElement;
        tv.delegate = self;
        
        if ([self showPlaceholder]) {
            tv.text = self.placeholder;
        }
        else {
            tv.text = self.value;
        }
        
        self.showDoneButton = YES;
    }
    
    self.uiField = uiElement;
    self.type = type;
    
    if (type == BHPulseValueType_Email) {
        [self.uiField setKeyboardType:UIKeyboardTypeEmailAddress];
    }
    else if (type == BHPulseValueType_Digits) {
        [self.uiField setKeyboardType:UIKeyboardTypeNumberPad];
        self.showDoneButton = YES;
    }
    else if (type == BHPulseValueType_Password) {
        [self.uiField setSecureTextEntry:YES];
    }
    else if (type == BHPulseValueType_PhoneNumber) {
        [self.uiField setKeyboardType:UIKeyboardTypePhonePad];
        self.showDoneButton = YES;
    }
}

- (void)setValue:(id)value {

    self.isValid = YES;
    
    if (self.validateValueBlock) {
        self.isValid = self.validateValueBlock(self.key, value);
    }
    else {
        self.isValid = [self validateValue:value];
    }

    _value = value;
    
    if (self.uiField) {
        [self.uiField setText:_value];
    }
    
    [self.context notifyValueDidChange:self];
}

- (BOOL)validateValue:(id)value {
    
    if (self.type == BHPulseValueType_Text) {
        
        if ([value isKindOfClass:[NSString class]]) {
            return [value length] > 0;
        }
        else {
            return NO;
        }
    }
    else if (self.type == BHPulseValueType_Email) {
        
        if (value == nil) {
            return NO;
        }
        
        BOOL found = ([value rangeOfString:@"@"].location != NSNotFound) && ([value rangeOfString:@"."].location != NSNotFound);
        
        return found;
    }
    else if (self.type == BHPulseValueType_PhoneNumber) {
        
        if ([value isKindOfClass:[NSString class]]) {
            return [value length] > 0;
        }
        else {
            return NO;
        }
    }
    else
        return YES;
}

- (void)addDoneButton:(BHPulseValue*)value {
    
    if ([self.uiField inputAccessoryView] != nil) {
        return;
    }
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSString *label;
    
    if (value.isLastValue) {
        label = @"Done";
    }
    else {
        label = @"Next";
    }
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:label style:UIBarButtonItemStylePlain target:self action:@selector(handleDoneButtonTapped:)];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    toolbar.items = @[spacer, barButton];
    
    [value.uiField setInputAccessoryView: toolbar];
}

- (void)handleDoneButtonTapped:(id)sender {
    [self.context notifyTextFieldShouldReturn:self];
}

@end
