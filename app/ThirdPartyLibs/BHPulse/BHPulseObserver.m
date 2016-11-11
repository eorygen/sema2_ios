//
//  BHPulseObserver.m
//  btq
//
//  Created by Ashemah Harrison on 13/08/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import "BHPulseObserver.h"
#import "BHPulseValue.h"

@implementation BHPulseObserver

- (instancetype)initWithContext:(BHPulseContext*)context andKeys:(NSArray*)keys andReactBlock:(ObserverBlock)reactBlock;
{
    self = [super init];
    if (self) {
        self.context = context;
        self.keys = [NSSet setWithArray:keys];
        self.reactBlock = reactBlock;
    }
    return self;
}

- (BOOL)isWatching:(BHPulseValue*)value {
    return [self.keys member:value.key] != nil;
}

- (void)reactToChange:(BHPulseValue*)value {
    
    if (self.reactBlock) {
        self.reactBlock(self.context, self);
    }
}

- (NSArray*)keysAsArray {
    return [self.keys allObjects];
}
@end
