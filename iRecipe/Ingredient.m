//
//  Ingredient.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 12/5/12.
//  Copyright (c) 2012 Stanimir Nikolov. All rights reserved.
//

#import "Ingredient.h"

@implementation Ingredient


- (id)initWithName:(NSString*)name amount:(NSString*)amount andMeasure:(NSString*)measure {
    self = [super init];
    if (self) {
        self.name = name;
        self.measure = measure;
        self.amount = amount;
        double value = 0.0f;
        if([amount rangeOfString:@" "].location != NSNotFound){
            //x y/z
            NSArray* allParts = [amount componentsSeparatedByString:@" "];
            NSString* beforeTheDot = ([allParts count] > 0) ? [allParts objectAtIndex:0] : @"0";
            NSString* afterTheDot = ([allParts count] > 1) ? [allParts objectAtIndex:1] : @"0";
            NSArray* afterTheDotParts = [afterTheDot componentsSeparatedByString:@"/"];
            NSString* firstSign = ([afterTheDotParts count] > 0) ? [afterTheDotParts objectAtIndex:0] : @"0";
            NSString* secondSign = ([afterTheDotParts count] > 1) ? [afterTheDotParts objectAtIndex:1] : @"1";
            double beforeTheDotDoubleValue = [beforeTheDot doubleValue];
            double firstPart = [firstSign doubleValue];
            double secondPart = [secondSign doubleValue];
            double afterTheDotDoubleValue = firstPart / secondPart;
            value = beforeTheDotDoubleValue + afterTheDotDoubleValue;
        }
        else{
            //just x or just y/x
            if([amount rangeOfString:@"/"].location == NSNotFound){
               //x
                value = [self.amount doubleValue];
            }
            else{
                NSArray* afterTheDotParts = [self.amount componentsSeparatedByString:@"/"];
                NSString* firstSign = ([afterTheDotParts count] > 0) ? [afterTheDotParts objectAtIndex:0] : @"0";
                NSString* secondSign = ([afterTheDotParts count] > 1) ? [afterTheDotParts objectAtIndex:1] : @"1";
                double firstPart = [firstSign doubleValue];
                double secondPart = [secondSign doubleValue];
                value = firstPart / secondPart;
            }
        }
        self.quantity = [NSNumber numberWithDouble:value];
    }
    return self;
}

@end
