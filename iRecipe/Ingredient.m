//
//  Ingredient.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 12/5/12.
//  Copyright (c) 2012 Stanimir Nikolov. All rights reserved.
//

#import "Ingredient.h"

@implementation Ingredient

@synthesize name;
@synthesize amount;
@synthesize measure;

- (id)initWithName:(NSString*)_name amount:(NSString*)_amount andMeasure:(NSString*)_measure {
    self = [super init];
    if (self) {
        self.name = _name;
        self.amount = _amount;
        if ([_measure isEqual:@""]) {
            self.measure = @"number";
        } else {
            self.measure = _measure;
        }
    }
    return self;
}

@end
