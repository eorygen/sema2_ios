//
//  BHBlockTableDyamicSection.h
//  btq
//
//  Created by Ashemah Harrison on 24/04/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import "BHBlockTableSection.h"

@interface BHBlockTableDynamicSection : BHBlockTableSection

@property (copy, nonatomic) NumberOfRowsBlock numberOfRows;

- (NSInteger)numberOfRowsInSection;

@end
