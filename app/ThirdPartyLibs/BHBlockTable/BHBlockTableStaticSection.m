//
//  BHBlockTableStaticSection.m
//  btq
//
//  Created by Ashemah Harrison on 24/04/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import "BHBlockTableStaticSection.h"
#import "BHBlockTableStaticSectionCellDef.h"
#import "BHBlockTable.h"

@implementation BHBlockTableStaticSection

- (instancetype)initWithParent:(BHBlockTable*)parent {
    
    self = [super initWithParent:parent];
    if (self) {
        self.items = [NSMutableArray array];
    }
    return self;
}

- (NSInteger)numberOfRowsInSection {
    
    if (!self.isOpen) {
        return 0;
    }

    self._cachedRowCount = [self.items count];
    return self._cachedRowCount;
}

- (void)removeAllRows {
    [self.items removeAllObjects];
}

- (void)addCellWithName:(NSString*)cellName {
    [self addCellWithName:cellName andId:-1];
}

- (void)addCellWithName:(NSString*)cellName andId:(NSInteger)cellId {
    
    BHBlockTableStaticSectionCellDef *def = [[BHBlockTableStaticSectionCellDef alloc] init];
    def.cellName = cellName;
    
    if (cellId != -1) {
        def.cellId = cellId;
    }
    else {
        def.cellId = [self.items count];
    }
    
    [self.items addObject:def];
    
    //
//    [self._parent registerNibForCellIdentifier:cellName];
}

- (NSString*)cellIdentifierForRow:(NSInteger)row {
    return [self.items[row] cellName];
}

- (NSInteger)cellIdForRow:(NSInteger)row {
    return [self.items[row] cellId];
}

@end
