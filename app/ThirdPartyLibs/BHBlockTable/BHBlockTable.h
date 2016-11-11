//
//  BHBlockTable.h
//  btq
//
//  Created by Ashemah Harrison on 24/04/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BHBlockTableDynamicSection.h"
#import "BHBlockTableStaticSection.h"
#import "BHBlockTableFRCSection.h"

@interface BHBlockTable : NSObject<UITableViewDataSource, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    
    int *_sectionIndex;
}

@property (retain, nonatomic) NSMutableArray *_sections;
@property (retain, nonatomic) NSMutableArray *_activeSections;
@property (retain, nonatomic) UITableView *tableView;
@property (assign, nonatomic) NSInteger _cachedSectionCount;
@property (retain, nonatomic) NSMutableDictionary *cellCache;
@property (copy, nonatomic) DidScrollToEndOfTable didScrollToEndOfTable;

- (BHBlockTableDynamicSection*)dynamicSection;
- (BHBlockTableDynamicSection*)dynamicSectionWithCellIdentifier:(NSString*)cellIdentifier headerViewClass:(NSString*)headerViewClass andVisibility:(BOOL)visibility;

- (BHBlockTableStaticSection*)staticSection;
- (BHBlockTableStaticSection*)staticSectionWithCellIdentifiers:(NSArray*)cellIdentifiers headerViewClass:(NSString*)headerClass andVisibility:(BOOL)visibility;

- (BHBlockTableFRCSection*)frcSection;

- (instancetype)initWithTableView:(UITableView*)tableView1;
- (void)refresh;

- (UITableViewCell*)cachedCellForIdentifier:(NSString*)identifier indexPath:(NSIndexPath*)indexPath;
- (void)removeSectionsInGroup:(NSInteger)group;
- (void)deleteRow:(NSInteger)row inSection:(NSInteger)section;
- (void)refreshRow:(NSInteger)row inSection:(NSInteger)section;
- (void)refreshRow2:(NSInteger)row inSection:(NSInteger)section;
- (NSIndexPath*)indexPathForCellSubView:(UIView*)view;
- (id)objectForIndexPath:(NSIndexPath*)indexPath;
- (BHBlockTableSection*)sectionForIndex:(NSInteger)index;
- (void)refreshSection:(NSInteger)section;
- (void)refreshSection:(NSInteger)section scrollToSection:(BOOL)scrollToSection;
- (void)setVisibility:(BOOL)visibility forSectionsInGroup:(NSInteger)group;
- (void)registerNibForCellIdentifier:(NSString*)cellIdentifier;

@end
