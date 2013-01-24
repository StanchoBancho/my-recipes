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

-(NSUInteger)getTheMedianIndexFromRecipes:(NSMutableArray*)recipes forIngredient:(Ingredient*)ingredient
{   NSArray *sorted = nil;
    sorted = [recipes sortedArrayWithOptions:NSSortStable usingComparator:^
              NSComparisonResult(id obj1, id obj2) {
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
                  
                  NSNumber* value1 = nil;
                  for(Ingredient* i in recipe1.ingredients){
                      if([i.name isEqualToString:ingredient.name]){
                          value1 = i.realValue;
                          break;
                      }
                  }
                  NSNumber* value2 = nil;
                  for(Ingredient* i in recipe2.ingredients){
                      if([i.name isEqualToString:ingredient.name]){
                          value2 = i.realValue;
                          break;
                      }
                  }
                  if(value1 == nil && value2 == nil){
                      return NSOrderedSame;
                  }
                  if(value1 == nil){
                      return NSOrderedAscending;
                  }
                  if(value2 == nil){
                      return NSOrderedDescending;
                  }
                  return [value1 compare:value2];
              }];
    
    NSUInteger middle = [sorted count] / 2;                                           // Find the index of the middle element
    Recipe *median = [sorted objectAtIndex:middle];
    NSUInteger result = [recipes indexOfObject:median];
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
        if([recipes count] == 1){
            self.location = [recipes lastObject];
        }
        else{
            //set location
            Ingredient* importantIngredient = (Ingredient*)[ingredients objectAtIndex:self.depth];
            NSUInteger locationIndex =  [self getTheMedianIndexFromRecipes:recipes forIngredient:importantIngredient];
            Recipe* location = (Recipe*)[recipes objectAtIndex:locationIndex];
            [self setLocation:location];
            
            //create left child
            NSUInteger leftLength = locationIndex == 0 ? 0 : (locationIndex - 1);
            NSRange leftRange = NSMakeRange(0, leftLength);
            NSMutableArray* leftRecipes = [NSMutableArray arrayWithArray:[recipes subarrayWithRange:leftRange]];
            Node* leftChild = [[Node alloc] initWithRecipes:leftRecipes andIngredients:ingredients andDepth:(self.depth+1)];
            [self setLeftChild:leftChild];
            
            //create right child
            NSUInteger rightLocation = locationIndex == ([recipes count] - 1) ? [recipes count] - 1 : (locationIndex + 1);
            NSRange rightRange = NSMakeRange(rightLocation, [recipes count] - rightLocation);
            NSMutableArray* rightRecipes = [NSMutableArray arrayWithArray:[recipes subarrayWithRange:rightRange]];
            Node* rightChild = [[Node alloc] initWithRecipes:rightRecipes andIngredients:ingredients andDepth:(self.depth+1)];
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

@end
