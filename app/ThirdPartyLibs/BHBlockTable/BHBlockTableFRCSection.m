//
//  BHBlockTableFRCSection.m
//  btq
//
//  Created by Ashemah Harrison on 27/04/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import "BHBlockTableFRCSection.h"

@implementation BHBlockTableFRCSection

- (instancetype)initWithParent:(BHBlockTable<NSFetchedResultsControllerDelegate>*)parent {
    
    self = [super init];
    if (self) {
        self._parent = parent;
        self.info = [[BHBlockTableInfo alloc] init];
        self._sectionIndex = 0;
        self.isVisible = YES;
        self.dataSectionIndex = 0;
        self.isOpen = YES;
    }
    return self;
}

- (void)setFrc:(NSFetchedResultsController *)frc andPerformFetch:(BOOL)performFetch {
    
    self._frc = frc;
    self._frc.delegate = self._parent;
    
    if (performFetch) {
        [self._frc performFetch:nil];
    }
}

- (void)configureCell:(id)cell forSectionRow:(NSInteger)row {
    self.info.row = row;
    self.info.cell = cell;
    
    self.info.isFirstRow = (row == 0);
    self.info.isLastRow = (row == self._cachedRowCount-1);
    
    self.info.sectionObj = self;
    
    self.info.obj = [self._frc objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:self.dataSectionIndex]];
    
    self.info.section = self._sectionIndex;
    self.configureCellForRow(self.info);
}

- (NSInteger)sectionIndex {
    return self._sectionIndex;
}

- (NSInteger)numberOfRowsInSection {

    if (!self.isOpen) {
        return 0;
    }
    
    id  sectionInfo = [[self._frc sections] objectAtIndex:self.dataSectionIndex];
    return [sectionInfo numberOfObjects];
}

- (id)objectForRow:(NSInteger)row {
    return [self._frc objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:self.dataSectionIndex]];
}

@end
