    //
//  BHBlockTableSection.m
//  btq
//
//  Created by Ashemah Harrison on 24/04/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import "BHBlockTableSection.h"
#import "BHBlockTable.h"

@implementation BHBlockTableSection

- (instancetype)initWithParent:(BHBlockTable*)parent {
    
    self = [super init];
    if (self) {
        self._parent = parent;
        self.info = [[BHBlockTableInfo alloc] init];
        self._sectionIndex = 0;
        self.isVisible = YES;
        self.staticTableHeight = -1;
        self.emptyCellIdentifier = nil;
        self.isEmpty = YES;
        self.isOpen = YES;
        self._lastTappedRow = -1;
    }
    return self;
}

- (void)setupInfoForRow:(NSInteger)row {
    
    self.info.lastTappedRow = self._lastTappedRow;
    
    self._curRow = row;
    self.info.row = self._curRow;
    
    self.info.section = self._sectionIndex;
    self.info.sectionObj = self;
    self.info.refreshMode = BHBlockTableRefreshMode_None;
    self.info.cellId = [self cellIdForRow:row];
    
    self.info.isFirstRow = (row == 0);
    self.info.isLastRow = (row == self._cachedRowCount-1);
    
    self.info.sectionObj = self;
}

- (NSInteger)rowCount {
    return 0;
}

- (NSInteger)sectionIndex {
    return self._sectionIndex;
}

- (NSInteger)_numberOfSections {
    return 0;
}

- (NSInteger)numberOfRowsInSection {
    return 0;
}

- (void)setLastTappedRowIndex:(NSInteger)row {
    self._lastTappedRow = row;
}

- (BHBlockTableInfo*)didSelectSectionRow:(NSInteger)row {

    [self setupInfoForRow:row];
    
    if (self.didSelectRow) {
        self.didSelectRow(self.info);
    }
    
    return self.info;
}

- (CGFloat)heightForSectionRow:(NSInteger)row {

    [self setupInfoForRow:row];
    
    NSString *cellIdentifier;
    
    if (self.isEmpty && self.emptyCellIdentifier != nil) {
        cellIdentifier = self.emptyCellIdentifier;
    }
    else {
        cellIdentifier = [self cellIdentifierForRow:row];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:self._sectionIndex];
    UITableViewCell *cell = [self._parent cachedCellForIdentifier:cellIdentifier indexPath:indexPath];

    NSAssert(cell, @"Cell not found for identifier %@", cellIdentifier);
    
    self.info.cell = cell;
    
    if (self.heightForRow) {
        return self.heightForRow(self.info);
    }
    else if (self.staticTableHeight > 0) {
        return self.staticTableHeight;
    }
    else {
        self.info.isCalculatingHeight = YES;        
        [self configureCell:cell forSectionRow:row];
        
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        cell.bounds = CGRectMake(0.0f,0.0f, CGRectGetWidth(self._parent.tableView.bounds), CGRectGetHeight(cell.bounds));
        [cell layoutIfNeeded];
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        if (size.height == 0) {
            NSLog(@"Warning: Cell height is zero!");
        }
        
        return size.height;
    }
}

- (void)configureCell:(id)cell forSectionRow:(NSInteger)row {

    [self setupInfoForRow:row];
    
    self.info.cell = cell;
    
    if (self.isEmpty && self.emptyCellIdentifier != nil) {
        
        if (self.configureEmptyCellForRow) {
            self.configureEmptyCellForRow(self.info);
        }
        
        UITableViewCell *curCell = cell;
        curCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        if (self.configureCellForRow) {
            self.configureCellForRow(self.info);
        }
        
        if (!self.didSelectRow) {
            UITableViewCell *curCell = cell;
            curCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
}

- (void)configureSectionHeaderView:(id)headerView {
    
    self.info.section = self._sectionIndex;
    self.info.view = headerView;
    self.info.isOpen = self.isOpen;
    
    if (self.configureHeaderView) {
        self.configureHeaderView(self.info);
    }
}

- (void)setCellIdentifier:(NSString *)cellIdentifier {
    _cellIdentifier = cellIdentifier;
//    [self._parent registerNibForCellIdentifier:cellIdentifier];
}

- (id)objectForRow:(NSInteger)row {
    return nil;
}

- (NSInteger)cellIdForRow:(NSInteger)row {
    return row;
}

- (NSString*)cellIdentifierForRow:(NSInteger)row {
    return self.cellIdentifier;
}

- (IBAction)toggleVisibility:(id)sender {
    self.isVisible = !self.isVisible;
    [self._parent refresh];
}

- (void)setIsVisible:(BOOL)isVisible1 animated:(BOOL)animated {
    self.isVisible = isVisible1;
    [self refresh];
}

- (void)swipeDeleteRowAtIndex:(NSInteger)row {
    [self _deleteSectionRowAtIndex:row];
    [self removeRowAtIndex:row];
}

- (void)removeRowAtIndex:(NSInteger)row {

    NSInteger curRowCount = [self numberOfRowsInSection];
    
    BHBlockTableRefreshMode refreshMode = [self _deleteSectionRowAtIndex:row];

    NSInteger newRowCount = [self numberOfRowsInSection];
    
    BOOL removeRow = curRowCount != newRowCount;
    
    [self._parent.tableView beginUpdates];
    
    if (refreshMode != BHBlockTableRefreshMode_None) {
        
        if (removeRow) {
            [self._parent deleteRow:row inSection:self._sectionIndex];
        }
        else {
            [self._parent refreshRow2:row inSection:self._sectionIndex];
        }
    }
    
    [self._parent.tableView endUpdates];
}

- (BHBlockTableRefreshMode)_deleteSectionRowAtIndex:(NSInteger)row {
    
    [self setupInfoForRow:row];
    self.info.rowsToRefresh = nil;
    
    self.info.refreshMode = BHBlockTableRefreshMode_None;
    
    if (self.removeRow) {
        self.removeRow(self.info);
    }
    
    return self.info.refreshMode;
}

- (void)refresh {
    [self._parent.tableView reloadSections:[NSIndexSet indexSetWithIndex:self._sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
