//
//  BHPulseObserver.h
//  btq
//
//  Created by Ashemah Harrison on 13/08/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BHPulseDefines.h"

@interface BHPulseObserver : NSObject

@property (retain, nonatomic) BHPulseContext *context;
@property (copy, nonatomic) ObserverBlock reactBlock;
@property (retain, nonatomic) NSSet *keys;

- (instancetype)initWithContext:(BHPulseContext*)context andKeys:(NSArray*)keys andReactBlock:(ObserverBlock)reactBlock;
- (BOOL)isWatching:(BHPulseValue*)value;
- (void)reactToChange:(BHPulseValue*)value;
- (NSArray*)keysAsArray;

@end
