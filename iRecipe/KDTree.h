//
//  KDTree.h
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/24/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@protocol ProgresVisualizer <NSObject>

-(void)theProgressOfTheTaskIs:(float)progress;

@end

@interface KDTree : NSObject


-(id)initWithIngredients:(NSMutableArray*)ingredients andDelegate: (id<ProgresVisualizer>)delegate;

-(NSMutableArray*)theNearestNeighbour;
-(Recipe*)trivialSearch;
-(void)print;

@end
