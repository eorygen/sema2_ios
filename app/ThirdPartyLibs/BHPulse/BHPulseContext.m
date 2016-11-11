//
//  Pulse.m
//  safe_d
//
//  Created by Ashemah Harrison on 2/9/14.
//  Copyright (c) 2014 Ashemah Harrison. All rights reserved.
//

#import "BHPulseContext.h"

@implementation BHPulseContext

+ (BHPulseContext *)shared {
    
    static BHPulseContext *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[BHPulseContext alloc] init];
    });
    
    return _sharedClient;
}

- (void)dealloc {
    
}

+ (BHPulseContext *)contextWithViewController:(UIViewController*)vc {
    return [[BHPulseContext alloc] init];
}

- (id)init {
    
    self = [super init];
    if (self) {
        self.data = [NSMutableDictionary dictionary];
        self.uiBindings = [NSMutableArray array];
    }
    
    return self;
}

- (BHPulseValue*)getEntryForKey:(NSString*)key {
    
    BHPulseValue *entry = self.data[key];
    return entry;
}

- (BHPulseValue*)getOrCreateEntryForKey:(NSString*)key {
    
    BHPulseValue *entry = self.data[key];
    
    if (!entry) {
        entry = [[BHPulseValue alloc] init];
        entry.dependents = [NSMutableSet set];
        entry.key = key;
        entry.value = nil;
        entry.context = self;
        entry.isRequired = YES;
        self.data[key] = entry;
    }

    return entry;
}

- (void)setBoolValue:(BOOL)value forKey:(NSString *)key {
    
    BHPulseValue *entry = [self getOrCreateEntryForKey:key];
    entry.value = [NSNumber numberWithBool:value];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    
    BHPulseValue *entry = [self getOrCreateEntryForKey:key];
    entry.value = value;
}

- (id)valueForKey:(NSString*)key {
    
    BHPulseValue *entry = self.data[key];
    return entry.value;
}

- (NSString*)stringValueForKey:(NSString*)key {
    
    BHPulseValue *entry = self.data[key];
    return [entry stringValue];
}

- (BOOL)boolValueForKey:(NSString*)key {
    return [[self valueForKey:key] boolValue];
}
- (BHPulseValue*)bindUI:(id)uiElement forKey:(NSString*)key andType:(BHPulseValueType)type {
    return [self bindUI:uiElement forKey:key andType:type isRequired:YES];
}

- (BHPulseValue*)bindUI:(id)uiElement forKey:(NSString*)key andType:(BHPulseValueType)type isRequired:(BOOL)isRequired {
    return [self bindUI:uiElement forKey:key andType:type andPlaceholder:@"" isRequired:isRequired];
}

- (BHPulseValue*)bindUI:(id)uiElement forKey:(NSString*)key andType:(BHPulseValueType)type andPlaceholder:(NSString*)placeholder isRequired:(BOOL)isRequired {
    
    BHPulseValue *entry = [self getEntryForKey:key];
    
    if (!entry) {
        entry = [self getOrCreateEntryForKey:key];
        [self.uiBindings addObject:entry];
        
        [self.lastValue setNextValue:entry];
        [self.lastValue setIsLastValue:NO];
        
        self.lastValue = entry;
        entry.isLastValue = YES;
    }

    entry.isRequired = isRequired;
    entry.placeholder = placeholder;
    
    //
    [uiElement setText:[self stringValueForKey:key]];
    
    [entry setUIElement:uiElement andType:type];
    
    return entry;
}

- (BOOL)notifyTextFieldShouldReturn:(BHPulseValue*)value {
    
    if (value.nextValue) {
        [value.nextValue.uiField becomeFirstResponder];
    }
    else {
        [value.uiField resignFirstResponder];
    }
    
    return YES;
    
}

- (void)setDependencies:(NSArray*)dependencies forKey:(NSString*)key {
    
    for (NSString *dependentKey in dependencies) {
        BHPulseValue *entry = self.data[dependentKey];
        [entry.dependents addObject:key];
    }
}

- (NSDictionary*)dataDictionary {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (NSString *key in [self.data allKeys]) {
        BHPulseValue *entry = [self getEntryForKey:key];
        if (entry.value) {
            [dict setObject:entry.value forKey:key];
        }
    }
         
    return dict;
}

- (void)notifyValueDidChange:(BHPulseValue*)value {

    // Iterate the observers and notify them of a change
    for (BHPulseObserver *obs in self.observers) {
        if ([obs isWatching:value]) {
            [obs reactToChange:value];
        }
    }
}

- (void)setValues:(NSArray*)keys fromDictionary:(NSDictionary*)dictionary {
    [self setValues:keys withKeyPrefix:nil fromDictionary:dictionary];
}

- (void)setValues:(NSArray*)keys withKeyPrefix:(NSString*)prefix fromDictionary:(NSDictionary*)dictionary {
    
    if (!keys) {
        keys = [dictionary allKeys];
    }
    
    NSString *fullKey;
    
    for (__strong NSString *key in keys) {
        
        if (prefix) {
            fullKey = [prefix stringByAppendingString:key];
        }
        else {
            fullKey = key;
        }
        
        BHPulseValue *entry = [self getOrCreateEntryForKey:fullKey];
        
        if (dictionary[key] != nil) {
            entry.value = dictionary[key];
        }
    }
}

- (void)observe:(NSArray*)keys andReact:(ObserverBlock)changeBlock {

    if (!self.observers) {
        self.observers = [NSMutableArray array];
    }
    
    if (!keys) {
        keys = [self allKeys];
    }
    
    BHPulseObserver *obs = [[BHPulseObserver alloc] initWithContext:self andKeys:keys andReactBlock:changeBlock];
    [self.observers addObject:obs];

}

- (NSArray*)allKeys {
    return [self.data allKeys];
}

- (BOOL)allValid:(NSArray*)keys {
    
    if (!keys) {
        keys = [self.data allKeys];
    }
    
    for (NSString *key in keys) {
        BHPulseValue *entry = [self getEntryForKey:key];
        if (!entry.isValid && entry.isRequired) {
            return NO;
        }
    }
    
    return YES;
}

@end
