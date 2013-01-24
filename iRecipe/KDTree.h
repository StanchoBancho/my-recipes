//
//  KDTree.h
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/24/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDTree : NSObject

-(id)initWithRecipes:(NSMutableArray*)recipes andIngredients:(NSMutableArray*)ingredients;

@end
