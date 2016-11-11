//
//  BHBlockTableStaticSection.h
//  btq
//
//  Created by Ashemah Harrison on 24/04/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import "BHBlockTableSection.h"

@class BHBlockTable;

@interface BHBlockTableStaticSection : BHBlockTableSection {
    
}

@property (retain, nonatomic) BHBlockTable *parent;
@property (retain, nonatomic) NSMutableArray *items;

- (instancetype)initWithParent:(BHBlockTable*)parent;
- (void)addCellWithName:(NSString*)cellName;
- (void)addCellWithName:(NSString*)cellName andId:(NSInteger)cellId;
- (void)removeAllRows;

@end
