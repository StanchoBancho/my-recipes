//
//  Node.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/24/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "Node.h"
#import "Ingredient.h"

@implementation Node

-(void)sortIngredients:(NSMutableArray*)recipes inOrderOfIngredient:(Ingredient*)ingredient
{
    [recipes sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Recipe* recipe1 = (Recipe*) obj1;
        Recipe* recipe2 = (Recipe*) obj2;
        if(recipe1 == nil && recipe2 == nil){
            return NSOrderedSame;
        }
        if(recipe1 == nil){
            return NSOrderedAscending;
        }
        if (recipe2 == nil) {
            return NSOrderedDescending;
        }
        
        double value1 = .0f;
        for(Ingredient* i in recipe1.ingredients){
            if([i.name isEqualToString:ingredient.name]){
                value1 = i.realValue;
                break;
            }
        }
        double value2 = .0f;
        for(Ingredient* i in recipe2.ingredients){
            if([i.name isEqualToString:ingredient.name]){
                value2 = i.realValue;
                break;
            }
        }
        if(value1 == .0f && value2 == .0f){
            return NSOrderedSame;
        }
        if(value1 == .0f){
            return NSOrderedAscending;
        }
        if(value2 == .0f){
            return NSOrderedDescending;
        }
        
        if (value1 < value2) {
            return NSOrderedAscending;
        }
        if (value1 > value2) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
}

-(NSUInteger)getTheLocationIndexInIngredients:(NSMutableArray*)ingredients andPivot:(Recipe*)pivot andImportentIngredient:(Ingredient*)importentIngredient
{
    double theValueInTheMiddle = 0;
    for(Ingredient* i in pivot.ingredients){
        if([i.name isEqualToString:importentIngredient.name]){
            theValueInTheMiddle = i.realValue;
            break;
        }
    }
    NSUInteger result = 0;
    for(NSUInteger r = 0; r < ingredients.count; r++){
        Recipe* currentRecipe = [ingredients objectAtIndex:r];
        double currentRecipeImportentIngredientValue = 0;
        for (Ingredient* i in currentRecipe.ingredients) {
            if([i.name isEqualToString:importentIngredient.name]){
                currentRecipeImportentIngredientValue = i.realValue;
                break;
            }
        }
        if(currentRecipeImportentIngredientValue >= theValueInTheMiddle){
            result = r;
            break;
        }
    }
    return result;
}

-(id)initWithRecipes:(NSMutableArray*)recipes andIngredients:(NSMutableArray*)ingredients andDepth:(NSInteger) depth
{
    self = [super init];
    if(self){
        if(!recipes || [recipes count] == 0){
            return nil;
        }
        if(depth == [ingredients count]){
            [self setDepth:0];
        }
        else{
            [self setDepth:depth];
        }
        self.distanceToSearchPoint = DBL_MAX;
        if([recipes count] == 1){
            self.location = [recipes lastObject];
        }
        else{
            //set location
            Ingredient* importantIngredient = (Ingredient*)[ingredients objectAtIndex:self.depth];
            [self sortIngredients:recipes inOrderOfIngredient:importantIngredient];
            NSUInteger medianIndex =  [recipes count] / 2; // Find the index of the middle element
            Recipe* median = (Recipe*)[recipes objectAtIndex:medianIndex];
            NSUInteger locationIndex = [self getTheLocationIndexInIngredients:recipes andPivot:median andImportentIngredient:importantIngredient];
            self.location = [recipes objectAtIndex:locationIndex];
            
            //create left child
            NSUInteger leftLength = locationIndex == 0 ? 0 : (locationIndex - 1);
            NSRange leftRange = NSMakeRange(0, leftLength);
            NSMutableArray* leftRecipes = [NSMutableArray arrayWithArray:[recipes subarrayWithRange:leftRange]];
            Node* leftChild = [[Node alloc] initWithRecipes:leftRecipes andIngredients:ingredients andDepth:(self.depth+1)];
            [leftChild setParent:self];
            [self setLeftChild:leftChild];
            
            //create right child
            NSUInteger rightLocation = locationIndex == ([recipes count] - 1) ? [recipes count] - 1 : (locationIndex + 1);
            NSRange rightRange = NSMakeRange(rightLocation, [recipes count] - rightLocation);
            NSMutableArray* rightRecipes = [NSMutableArray arrayWithArray:[recipes subarrayWithRange:rightRange]];
            Node* rightChild = [[Node alloc] initWithRecipes:rightRecipes andIngredients:ingredients andDepth:(self.depth+1)];
            [rightChild setParent:self];
            [self setRightChild:rightChild];
        }
    }
    return self;
}

-(void)print
{
    printf("(");
    [self.leftChild print];
    printf("%s",[self.location.name UTF8String]);
    [self.rightChild print];
    printf(")");
}

- (NSInteger)value
{
    return (NSInteger)floor(self.distanceToSearchPoint);
}

@end
