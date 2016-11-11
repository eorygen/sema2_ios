//
//  BHBlockTableInfo.h
//  btq
//
//  Created by Ashemah Harrison on 24/04/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BHBlockTableRefreshMode_None,
    BHBlockTableRefreshMode_Row,
    BHBlockTableRefreshMode_Section
} BHBlockTableRefreshMode;

@class BHBlockTableSection;

@interface BHBlockTableInfo : NSObject

@property (assign, nonatomic) NSInteger lastTappedRow;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSInteger section;
@property (assign, nonatomic) BOOL isOpen;
@property (retain, nonatomic) id cell;
@property (retain, nonatomic) id view;
@property (assign, nonatomic) BOOL isFirstRow;
@property (assign, nonatomic) BOOL isLastRow;
@property (assign, nonatomic) BOOL isCalculatingHeight;
@property (retain, nonatomic) BHBlockTableSection *sectionObj;
@property (assign, nonatomic) BHBlockTableRefreshMode refreshMode;
@property (retain, nonatomic) NSMutableArray *rowsToRefresh;
@property (assign, nonatomic) id obj;
@property (assign, nonatomic) NSInteger cellId;

- (void)addRowToRefresh:(NSInteger)rowIndex;

@end
