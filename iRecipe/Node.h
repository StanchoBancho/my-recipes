//
//  Node.h
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/24/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Recipe.h"

@interface Node : NSObject

@property(nonatomic, strong) Node* leftChild;
@property(nonatomic, strong) Node* rightChild;
@property(nonatomic, strong) Recipe* location;
@property(nonatomic, assign) NSInteger* depth;

@end
