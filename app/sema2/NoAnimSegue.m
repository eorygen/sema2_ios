//
//  NoAnimSegue.m
//  sema2
//
//  Created by Ashemah Harrison on 24/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "NoAnimSegue.h"

@implementation NoAnimSegue

-(void) perform {
    [[self sourceViewController] presentViewController:[self destinationViewController] animated:NO completion:^{}];
}

@end
