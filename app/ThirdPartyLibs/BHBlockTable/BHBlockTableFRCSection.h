//
//  BHBlockTableFRCSection.h
//  btq
//
//  Created by Ashemah Harrison on 27/04/2014.
//  Copyright (c) 2014 Beat the Q. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BHBlockTableSection.h"

@interface BHBlockTableFRCSection : BHBlockTableSection {
    
}

@property (retain, nonatomic) NSFetchedResultsController *_frc;
@property (assign, nonatomic) NSInteger dataSectionIndex;

- (void)setFrc:(NSFetchedResultsController *)frc andPerformFetch:(BOOL)performFetch;

@end
