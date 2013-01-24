//
//  Ingredient.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 12/5/12.
//  Copyright (c) 2012 Stanimir Nikolov. All rights reserved.
//

#import "Ingredient.h"

@interface Ingredient()

@property (nonatomic, strong) NSString *amount;

@end

@implementation Ingredient

-(double)calculateQuantity
{
    double value = 0.0f;
    if([self.amount rangeOfString:@" "].location != NSNotFound){
        //x y/z
        NSArray* allParts = [self.amount componentsSeparatedByString:@" "];
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
        if([self.amount rangeOfString:@"/"].location == NSNotFound){
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
    return value;
}

-(double)calculateRealValueMultiplier
{
    //we will use grams for these measure
    double multiplier = 1;
    if([self.measure isEqualToString:@"cup"]){
        multiplier = 250;
    } else if([self.measure isEqualToString:@"quart"]){
        multiplier = 0.25;
    } else if([self.measure isEqualToString:@"tablespoon"]){
        multiplier = 15;
    } else if([self.measure isEqualToString:@"ounce"]){
        multiplier = 28.3495;
    } else if([self.measure isEqualToString:@"teaspoon"]){
        multiplier = 5.0;
    } else if([self.measure isEqualToString:@"pound"]){
        multiplier = 373.2417216;
    } else if([self.measure isEqualToString:@"drop"]){
        multiplier = 0.5;
    } else if([self.measure isEqualToString:@"can"]){
        multiplier = 300.0;
    } else if([self.measure isEqualToString:@"package"]){
        multiplier = 300.0;
    } else if([self.measure isEqualToString:@"square"]){
        multiplier = 15.0;
    } else if([self.measure isEqualToString:@"jar"]){
        multiplier = 250.0;
    } else if([self.measure isEqualToString:@"pinch"]){
        multiplier = 0.20;
    } else if([self.measure isEqualToString:@"sprig"]){
        multiplier = 10.0;
    } else if([self.measure isEqualToString:@"stalk"]){
        multiplier = 10.0;
    } else if([self.measure isEqualToString:@"stalk"]){
        multiplier = 40.0;
    } else if([self.measure isEqualToString:@"box"]){
        multiplier = 250.0;
    } else if([self.measure isEqualToString:@"bag"]){
        multiplier = 250.0;
    } else if([self.measure isEqualToString:@"tablespoo"]){
        multiplier = 15.0;
    }  else if([self.measure isEqualToString:@"spray"]){
        multiplier = 50.0;
    } else if([self.measure isEqualToString:@"gallon"]){
        multiplier = 4404.8838;
    } else if([self.measure isEqualToString:@"large can"]){
        multiplier = 800.0;
    }  else if([self.measure isEqualToString:@"carton"]){
        multiplier = 250.0;
    } else if([self.measure isEqualToString:@"container"]){
        multiplier = 250.0;
    }
    
    //exceptions
    if([self.name isEqualToString:@"garlic"]){
        multiplier = 1;
    }
    return multiplier;
}

- (id)initWithName:(NSString*)name amount:(NSString*)amount andMeasure:(NSString*)measure {
    self = [super init];
    if (self) {
        self.name = name;
        self.measure = measure;
        self.amount = amount;
        double value = [self calculateQuantity];
        self.quantity = [NSNumber numberWithDouble:value];
        double realValueMultiplier = [self calculateRealValueMultiplier];
        self.realValue = [NSNumber numberWithDouble:(value * realValueMultiplier)];
    }
    return self;
}

@end
