//
//  KDTree.h
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/24/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@interface KDTree : NSObject


-(id)initWithIngredients:(NSMutableArray*)ingredients;

-(NSMutableArray*)theNearestNeighbour;
-(Recipe*)trivialSearch;
-(void)print;

@end
