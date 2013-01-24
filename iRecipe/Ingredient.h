//
//  Ingredient.h
//  iRecipe
//
//  Created by Stanimir Nikolov on 12/5/12.
//  Copyright (c) 2012 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ingredient : NSObject

@property (nonatomic, strong) NSString* pid;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* measure;
@property (nonatomic, strong) NSNumber* quantity;
@property (nonatomic, strong) NSNumber* realValue;

- (id)initWithName:(NSString*)_name amount:(NSString*)_amount andMeasure:(NSString*)_measure;

@end
