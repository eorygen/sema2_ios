//
//  Pulse.h
//  safe_d
//
//  Created by Ashemah Harrison on 2/9/14.
//  Copyright (c) 2014 Ashemah Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BHPulseValue.h"
#import "BHPulseObserver.h"

@interface BHPulseContext : NSObject {
    
}

@property (nonatomic, retain) NSMutableDictionary *data;
@property (retain, nonatomic) NSMutableArray *uiBindings;
@property (retain, nonatomic) BHPulseValue *lastValue;
@property (retain, nonatomic) NSMutableArray *observers;

+ (BHPulseContext *)shared;
+ (BHPulseContext *)contextWithViewController:(UIViewController*)vc;

- (void)setBoolValue:(BOOL)value forKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;
- (id)valueForKey:(NSString*)key;
- (BOOL)boolValueForKey:(NSString*)key;

- (BHPulseValue*)bindUI:(id)uiElement forKey:(NSString*)key andType:(BHPulseValueType)type;
- (BHPulseValue*)bindUI:(id)uiElement forKey:(NSString*)key andType:(BHPulseValueType)type isRequired:(BOOL)isRequired;
- (BHPulseValue*)bindUI:(id)uiElement forKey:(NSString*)key andType:(BHPulseValueType)type andPlaceholder:(NSString*)placeholder isRequired:(BOOL)isRequired;

- (void)handleValueChange:(void(^)(NSString *name, id value))changeBlock forKey:(NSString*)key;
- (void)setDependencies:(NSArray*)dependencies forKey:(NSString*)key;
- (NSDictionary*)dataDictionary;

- (void)setValues:(NSArray*)keys fromDictionary:(NSDictionary*)dictionary;
- (void)setValues:(NSArray*)keys withKeyPrefix:(NSString*)prefix fromDictionary:(NSDictionary*)dictionary;

- (void)notifyValueDidChange:(BHPulseValue*)value;
- (BOOL)notifyTextFieldShouldReturn:(BHPulseValue*)value;

- (BOOL)allValid:(NSArray*)keys;

- (void)observe:(NSArray*)keys andReact:(ObserverBlock)changeBlock;

@end
