//
//  BHBlockTableSection.h
//  btq
//
//  Created by Ashemah Harrison on 24/04/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "BHBlockTableInfo.h"
#import "BHBlockTableTypes.h"

@class BHBlockTable;

@interface BHBlockTableSection : NSObject {
    
}

@property (assign, nonatomic) NSInteger _sectionIndex;
@property (retain, nonatomic) UIView *headerView;
@property (retain, nonatomic) BHBlockTable<NSFetchedResultsControllerDelegate> *_parent;
@property (retain, nonatomic) NSString *cellIdentifier;
@property (retain, nonatomic) BHBlockTableInfo *info;
@property (assign, nonatomic) BOOL isVisible;
@property (retain, nonatomic) NSString *headerViewClass;
@property (assign, nonatomic) NSInteger _cachedRowCount;
@property (assign, nonatomic) NSInteger _cachedSubSectionCount;
@property (assign, nonatomic) NSInteger sectionGroup;
@property (assign, nonatomic) NSInteger sortOrder;
@property (retain, nonatomic) NSMutableDictionary *userInfo;
@property (assign, nonatomic) NSInteger _lastTappedRow;
@property (assign, nonatomic) NSInteger _curRow;
@property (assign, nonatomic) CGFloat staticTableHeight;
@property (retain, nonatomic) NSString *emptyCellIdentifier;
@property (assign, nonatomic) BOOL isEmpty;
@property (assign, nonatomic) BOOL isOpen;

@property (copy, nonatomic) DidSelectRowBlock didSelectRow;
@property (copy, nonatomic) ConfigureCellForRowBlock configureCellForRow;
@property (copy, nonatomic) ConfigureEmptyCellForRowBlock configureEmptyCellForRow;
@property (copy, nonatomic) HeightForRowBlock heightForRow;
@property (copy, nonatomic) ConfigureHeaderViewBlock configureHeaderView;
@property (copy, nonatomic) RemoveRowBlock removeRow;

- (instancetype)initWithParent:(BHBlockTable*)parent;

- (NSInteger)numberOfRowsInSection;
- (BHBlockTableInfo*)didSelectSectionRow:(NSInteger)row;
- (CGFloat)heightForSectionRow:(NSInteger)row;
- (void)configureCell:(id)cell forSectionRow:(NSInteger)row;
- (void)configureSectionHeaderView:(id)headerView;
- (void)swipeDeleteRowAtIndex:(NSInteger)row;
- (NSString*)cellIdentifierForRow:(NSInteger)row;
- (IBAction)toggleVisibility:(id)sender;

- (void)removeRowAtIndex:(NSInteger)row;
- (BHBlockTableRefreshMode)_deleteSectionRowAtIndex:(NSInteger)row;

- (id)objectForRow:(NSInteger)row;

- (void)refresh;
- (void)setLastTappedRowIndex:(NSInteger)row;
- (void)setIsVisible:(BOOL)isVisible1 animated:(BOOL)animated;

@end
