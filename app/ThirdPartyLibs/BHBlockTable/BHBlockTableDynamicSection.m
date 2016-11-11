//
//  BHBlockTableDyamicSection.m
//  btq
//
//  Created by Ashemah Harrison on 24/04/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import "BHBlockTableDynamicSection.h"

@implementation BHBlockTableDynamicSection

- (NSInteger)numberOfRowsInSection {
    
    if (!self.isOpen) {
        return 0;
    }
    
    if (!self.numberOfRows) {
        NSAssert(NO, @"Dynamic sections require 'numberOfRows' block to be defined.");
    }
    
    self._cachedRowCount = self.numberOfRows(self.info);
    self.isEmpty = self._cachedRowCount == 0;
    
    if (self.isEmpty && self.emptyCellIdentifier != nil) {
        return 1;
    }
    else {
        return self._cachedRowCount;
    }
}

- (NSString*)cellIdentifierForRow:(NSInteger)row {
    if (self.isEmpty && self.emptyCellIdentifier != nil) {
        return self.emptyCellIdentifier;
    }
    else {
        return self.cellIdentifier;
    }
}

- (NSInteger)cellIdForRow:(NSInteger)row {
    return row;
}

@end
