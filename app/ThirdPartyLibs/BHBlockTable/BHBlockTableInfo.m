//
//  BHBlockTableInfo.m
//  btq
//
//  Created by Ashemah Harrison on 24/04/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import "BHBlockTableInfo.h"

@implementation BHBlockTableInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lastTappedRow = -1;
    }
    return self;
}

- (void)addRowToRefresh:(NSInteger)rowIndex {
    
    if (!self.rowsToRefresh) {
        self.rowsToRefresh = [NSMutableArray array];
    }
    
    if (rowIndex < 0) {
        return;
    }
    
    [self.rowsToRefresh addObject:[NSNumber numberWithInt:rowIndex]];
}
@end
