//
//  BHPulseDefines.h
//  btq
//
//  Created by Ashemah Harrison on 9/05/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#ifndef btq_BHPulseDefines_h
#define btq_BHPulseDefines_h

typedef enum {
    BHPulseValueType_Text,
    BHPulseValueType_Email,
    BHPulseValueType_Digits,
    BHPulseValueType_Password,
    BHPulseValueType_PhoneNumber
} BHPulseValueType;

@class BHPulseValue;
@class BHPulseContext;
@class BHPulseObserver;

#define BHPulseAllValues nil

#import <Foundation/Foundation.h>
#import "BHPulseDefines.h"

typedef void (^ObserverBlock)(BHPulseContext *ctx, BHPulseObserver *observer);
typedef id (^CalculateValueBlock)(NSString *name);
typedef BOOL (^ValidateValueBlock)(NSString *name, id value);
typedef BOOL (^TextFieldShouldReturn)(BHPulseValue *value);

#endif
