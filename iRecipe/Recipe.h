//
//  Recipe.h
//  iRecipe
//
//  Created by Stanimir Nikolov on 12/5/12.
//  Copyright (c) 2012 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Recipe : NSObject

@property (nonatomic, strong) NSString* pid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *howTo;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSNumber *preparationTime;
@property (nonatomic, strong) NSArray *ingredients;

@end
