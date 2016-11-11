//
//  BHBlockTable.m
//  btq
//
//  Created by Ashemah Harrison on 24/04/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import "BHBlockTable.h"

@implementation BHBlockTable

- (instancetype)initWithTableView:(UITableView*)tableView1 {
    
    self = [super init];
    if (self) {
        self._sections = [NSMutableArray array];
        self.tableView = tableView1;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.cellCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BHBlockTableStaticSection*)staticSection {
    BHBlockTableStaticSection *section = [[BHBlockTableStaticSection alloc] initWithParent:self];
    [self._sections addObject:section];
    return section;
}

- (BHBlockTableStaticSection*)staticSectionWithCellIdentifiers:(NSArray*)cellIdentifiers headerViewClass:(NSString*)headerClass andVisibility:(BOOL)visibility {
    
    BHBlockTableStaticSection *section = [self staticSection];
    
    for (NSString *ident in cellIdentifiers) {
        [section addCellWithName:ident];
    }
    
    section.headerViewClass = headerClass;
    section.isVisible = visibility;
    
    return section;
}

- (BHBlockTableDynamicSection*)dynamicSection {
    BHBlockTableDynamicSection *section = [[BHBlockTableDynamicSection alloc] initWithParent:self];
    [self._sections addObject:section];
    return section;
}

- (BHBlockTableDynamicSection*)dynamicSectionWithCellIdentifier:(NSString*)cellIdentifier headerViewClass:(NSString*)headerViewClass andVisibility:(BOOL)visibility {
    
    BHBlockTableDynamicSection *section = [self dynamicSection];
    
    section.cellIdentifier = cellIdentifier;
    section.headerViewClass = headerViewClass;
    section.isVisible = visibility;
    
    return section;
}

- (BHBlockTableFRCSection*)frcSection {
    BHBlockTableFRCSection *section = [[BHBlockTableFRCSection alloc] initWithParent:self];
    [self._sections addObject:section];
    return section;
}

- (BHBlockTableSection *)sectionForIndex:(NSInteger)index {
    return self._activeSections[index];
}

- (void)registerNibForCellIdentifier:(NSString*)cellIdentifier {
    UINib *nib = [UINib nibWithNibName:cellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == [self._activeSections count] -1) {
        BHBlockTableSection *section = [self sectionForIndex:indexPath.section];
        if (indexPath.row == [section numberOfRowsInSection]-1) {
            if (self.didScrollToEndOfTable) {
                self.didScrollToEndOfTable(self);
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BHBlockTableSection *curSection = [self sectionForIndex:indexPath.section];
    
    UITableViewCell *cell = nil;
    
    NSString *cellIdentifier = [curSection cellIdentifierForRow:indexPath.row];
    
    if (cellIdentifier != nil) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    }
    else {
        NSAssert(0, @"YOU MUST SET THE CELL NAME");
    }
    
    curSection.info.isCalculatingHeight = NO;
    [curSection configureCell:cell forSectionRow:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    BHBlockTableSection *curSection = [self sectionForIndex:section];
    NSInteger numberOfRows = [curSection numberOfRowsInSection];
    return numberOfRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self._cachedSectionCount;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BHBlockTableSection *curSection = [self sectionForIndex:indexPath.section];
    BHBlockTableInfo *info = [curSection didSelectSectionRow:indexPath.row];

    // Refresh if required
    if (info.refreshMode == BHBlockTableRefreshMode_Row) {

        [self.tableView beginUpdates];
        
        if (info.rowsToRefresh == nil) {
            [self refreshRow2:indexPath.row inSection:indexPath.section];
        }
        else {
            [self refreshRow2:indexPath.row inSection:indexPath.section];
            
            for (NSNumber *row in info.rowsToRefresh) {
                [self refreshRow2:[row intValue] inSection:indexPath.section];
            }
            
            info.rowsToRefresh = nil;
        }
        
        [self.tableView endUpdates];
    }
    else if (info.refreshMode == BHBlockTableRefreshMode_Section) {
        [self refreshSection:indexPath.section];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
}

- (void)deleteRow:(NSInteger)row inSection:(NSInteger)section {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)refreshRow:(NSInteger)row inSection:(NSInteger)section {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)refreshRow2:(NSInteger)row inSection:(NSInteger)section {
    
    BHBlockTableSection *curSection = [self sectionForIndex:section];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    curSection.info.isCalculatingHeight = NO;
    [curSection configureCell:cell forSectionRow:indexPath.row];
}

- (void)refreshSection:(NSInteger)section {
    [self refreshSection:section scrollToSection:NO];
}

- (void)refreshSection:(NSInteger)section scrollToSection:(BOOL)scrollToSection {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
    
    BHBlockTableSection *curSection = [self sectionForIndex:section];
    if (scrollToSection && curSection.isOpen && [curSection numberOfRowsInSection] > 0) {
        [self performSelector:@selector(scrollTableToSection:) withObject:[NSNumber numberWithInt:section] afterDelay:0.1];
    }
}

- (void)scrollTableToSection:(NSNumber*)section {
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[section intValue]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    BHBlockTableSection *curSection = [self sectionForIndex:indexPath.section];
    return [curSection heightForSectionRow:indexPath.row];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BHBlockTableSection *curSection = [self sectionForIndex:section];
    
    UIView *headerView = curSection.headerView;
    
    if (curSection.headerViewClass) {
        
        // Instantiate the headerview and then call configure on it
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:curSection.headerViewClass
                                                          owner:self
                                                        options:nil];
        
        headerView = [nibViews objectAtIndex:0];
    }
    
    if (headerView) {
        [curSection configureSectionHeaderView:headerView];
        curSection.headerView = headerView;
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    BHBlockTableSection *curSection = [self sectionForIndex:section];

    UIView *headerView = curSection.headerView;
    
    if (!headerView && curSection.headerViewClass) {
        
        headerView = self.cellCache[curSection.headerViewClass];
        
        if (!headerView) {
            
            // Instantiate the headerview and then call configure on it
            NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:curSection.headerViewClass
                                                              owner:self
                                                            options:nil];
            
            headerView = [nibViews objectAtIndex:0];
            self.cellCache[curSection.headerViewClass] = headerView;
        }
    }
    
    if (headerView) {
        [curSection configureSectionHeaderView:headerView];
        [headerView layoutIfNeeded];
        CGSize size = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return size.height;
    }
    else {
        return 0.05f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.05f;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        BHBlockTableSection *section = [self sectionForIndex:indexPath.section];
//        
//        [section swipeDeleteRowAtIndex:indexPath.row];
//    }
//}

- (id)objectForIndexPath:(NSIndexPath*)indexPath {
    BHBlockTableSection *section = [self sectionForIndex:indexPath.section];
    return [section objectForRow:indexPath.row];
}

- (void)refresh {
    
    self._cachedSectionCount = 0;
    
    self._activeSections = [NSMutableArray array];
    
    for (BHBlockTableSection *section in self._sections) {
        
        if (section.isVisible) {
            section._sectionIndex = self._cachedSectionCount;
            self._cachedSectionCount++;
            [self._activeSections addObject:section];
        }
    }
    
    [self.tableView reloadData];
}

- (void)removeSectionsInGroup:(NSInteger)group {
    
    self._sections = [[self._sections filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"sectionGroup != %@", group]] mutableCopy];
    
    [self refresh];
}

- (void)setVisibility:(BOOL)visibility forSectionsInGroup:(NSInteger)group {
    
    NSArray *sections = [self._sections filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"sectionGroup == %d", group]];
    
    for(BHBlockTableSection *section in sections) {
        section.isVisible = visibility;
    }
    
    [self refresh];
}

- (UITableViewCell*)cachedCellForIdentifier:(NSString*)identifier indexPath:(NSIndexPath*)indexPath {

    UITableViewCell *cell = self.cellCache[identifier];
    
    if (!cell) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        
        NSAssert(cell, @"Cannot create cached cell of type '%@'", identifier);
        
        self.cellCache[identifier] = cell;
    }
    
    return cell;
}

- (NSIndexPath*)indexPathForCellSubView:(UIView*)view {
    
    UIView *v = view;
    BOOL found = NO;
    
    while(v != nil && !found) {
        if ([v isKindOfClass:[UITableViewCell class]]) {
            found = YES;
        }
        else {
            v = [v superview];
        }
    }
    
    if (found) {
        return [self.tableView indexPathForCell:(UITableViewCell*)v];
    }
    else {
        return nil;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    BHBlockTableSection *curSection = [self sectionForIndex:indexPath.section];
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            curSection.info.isCalculatingHeight = NO;
            [curSection configureCell:[tableView cellForRowAtIndexPath:indexPath] forSectionRow:indexPath.row];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}
@end
