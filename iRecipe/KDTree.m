//
//  KDTree.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/24/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "KDTree.h"
#import "Ingredient.h"
#import "SQLiteReader.h"
#import "JCPriorityQueue.h"

@interface KDTree()

@property(nonatomic, strong) SQLiteReader* dbReader;
@property(nonatomic, strong) Node* root;
@property(nonatomic, strong) Recipe* searchPoint;

@property(nonatomic, strong) JCPriorityQueue* currentBestPQ;


@property(nonatomic, strong) NSMutableArray* allRecipes;
@end

@implementation KDTree

-(double)distanceBetweenRecipeOne:(Recipe*)recipeOne andRecipeTwo:(Recipe*)recipeTwo
{
    double result = 0.0f;
    for (Ingredient* i in self.searchPoint.ingredients) {
        //get the first ingredient
        Ingredient* one = nil;
        for (Ingredient* i1 in recipeOne.ingredients) {
            if([i1.name isEqualToString:i.name]){
                one = i1;
                break;
            }
        }
        //get the second ingredient
        Ingredient* two = nil;
        for (Ingredient* i2 in recipeTwo.ingredients) {
            if([i2.name isEqualToString:i.name]){
                two = i2;
                break;
            }
        }
        double value1 = 0.0f;
        if(one){
            value1 = one.realValue;
        }
        
        double value2 = 0.0f;
        if(two){
            value2 = two.realValue;
        }
        result += pow((value1 - value2), 2.0f);
    }
    return result;
}

#pragma mark - Initialization methods

-(void)populateIngredientsOfRecipe:(Recipe*)recipe
{
    //get ingredients info
    NSString* selectStatement = [NSString stringWithFormat:@"SELECT * FROM Relation WHERE recipeFk = %@",recipe.pid];
    NSMutableArray* ingredientsRelations = [self.dbReader readDBWithQuery:selectStatement];
    
    NSMutableArray* ingredients = [[NSMutableArray alloc] init];
    for(NSMutableArray* iRelation in ingredientsRelations){
        //setup each ingredient
        Ingredient* i = [[Ingredient alloc] init];
        
        NSString* ingredientFk = [iRelation objectAtIndex:1];
        [i setPid:ingredientFk];
        
        NSString* quantityString = [iRelation objectAtIndex:3];
        double quantity = [quantityString doubleValue];
        NSNumber* quantityNumber = [NSNumber numberWithDouble:quantity];
        [i setQuantity:quantityNumber];
        
        NSString* measure = [iRelation objectAtIndex:4];
        [i setMeasure:measure];
        
//        //forth way
//        NSString *val = [iRelation objectAtIndex:5];
//        //if ([val hasSuffix:@".0"]) {
//            NSRange r = [val rangeOfString:@"."];
//            r.length = val.length - r.location;
//            val = [val stringByReplacingCharactersInRange:r withString:@".58"];
//        //}
//        
//        [i setRealValue:[val doubleValue]];
        
//third way
//        NSScanner *scn = [NSScanner scannerWithString:[iRelation objectAtIndex:5]];
//        double ingredientRealValue = 0.0f;
//        [scn scanDouble:&ingredientRealValue];
//        ingredientRealValue += 0.001;
//        [i setRealValue:ingredientRealValue];
        
//second way
//        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//        [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
//        //NSNumber* value = [formatter numberFromString: [iRelation objectAtIndex:5]];
//        [i setRealValue:[[formatter numberFromString: [iRelation objectAtIndex:5]] doubleValue]];

//first way
        NSString* realValueString = [NSString stringWithFormat:@"%.2f", [[iRelation objectAtIndex:5] doubleValue]];
        double realValue = [realValueString doubleValue];
        [i setRealValue:realValue];
        
        //get the name of ingredient
        NSString* selectIngredientName = [NSString stringWithFormat:@"SELECT name FROM Ingredient WHERE id = %@",i.pid];
        NSMutableArray* ingredientNameResult = [self.dbReader readDBWithQuery:selectIngredientName];
        NSString* ingredientName = [[ingredientNameResult objectAtIndex:0] objectAtIndex:0];
        [i setName:ingredientName];
        
        [ingredients addObject:i];
    }
    [recipe setIngredients:ingredients];
}

-(Recipe*)populateRecipeWithId:(NSString*)recipeId
{
    Recipe* newRecipe = [[Recipe alloc] init];
    [newRecipe setUsed:NO];
    [newRecipe setPid:recipeId];
    NSString* selectStatement = [NSString stringWithFormat:@"SELECT * FROM Recipe WHERE id = %@",recipeId];
    NSMutableArray* recipeResult = [self.dbReader readDBWithQuery:selectStatement];
    
    NSString* name = [[recipeResult objectAtIndex:0] objectAtIndex:1];
    [newRecipe setName:name];
    
    NSString* howTo = [[recipeResult objectAtIndex:0] objectAtIndex:2];
    [newRecipe setHowTo:howTo];
    
    double preparationTime = [(NSString*)[[recipeResult objectAtIndex:0] objectAtIndex:3] doubleValue];
    NSNumber* preparationTimeNumber = [NSNumber numberWithDouble:preparationTime];
    [newRecipe setPreparationTime:preparationTimeNumber];
    
    [self populateIngredientsOfRecipe:newRecipe];
    
    return newRecipe;
}

-(NSMutableArray*)allRecipesThatMatchExistingIngridients
{
    //select desired recipe ids
    NSMutableString* selectRecipeIdStatement =[NSMutableString stringWithFormat:@"SELECT DISTINCT recipeFk FROM Relation WHERE "];
    for (int i = 0; i < self.searchPoint.ingredients.count; i++) {
        Ingredient* ingredient = [self.searchPoint.ingredients objectAtIndex:i];
        [selectRecipeIdStatement appendFormat:@"ingredientFk = %@",ingredient.pid];
        if(i != [self.searchPoint.ingredients count] - 1){
            [selectRecipeIdStatement appendFormat:@" OR "];
        }
    }
    NSMutableArray* result = [[NSMutableArray alloc] init];
    NSMutableArray* recipeIds = [self.dbReader readDBWithQuery:selectRecipeIdStatement];
    for(NSMutableArray* ids in recipeIds){
        NSString* recipeId = [ids objectAtIndex:0];
        Recipe* recipe = [self populateRecipeWithId:recipeId];
        [result addObject:recipe];
    }
    return result;
}

-(id)initWithIngredients:(NSMutableArray*)ingredients{
    self = [super init];
    if(self){
        Recipe* searchPoint = [[Recipe alloc] init];
        [searchPoint setIngredients:ingredients];
        self.searchPoint = searchPoint;

        self.dbReader = [[SQLiteReader alloc] init];
        NSMutableArray* allNeedRecipes = [self allRecipesThatMatchExistingIngridients];
        self.allRecipes = allNeedRecipes;
        NSLog(@"recipe count:%d",[allNeedRecipes count]);
        Node* root = [[Node alloc] initWithRecipes:allNeedRecipes andIngredients:ingredients andDepth:0];
        self.root = root;
    }
    return self;
}

#pragma mark - Operations methods

-(Recipe*)trivialSearch
{   double minDistance = DBL_MAX;
    Recipe* result = nil;
    for(Recipe* r in self.allRecipes){
        double curretnDisttance = [self distanceBetweenRecipeOne:r andRecipeTwo:self.searchPoint];
        //NSLog(@"distance is :%f",curretnDisttance);
        if(curretnDisttance < minDistance){
            minDistance = curretnDisttance;
            result = r;
        }
    }
    NSLog(@"FINAL distance is :%f", [self distanceBetweenRecipeOne:result andRecipeTwo:self.searchPoint]);
    return result;
}


-(NSMutableArray*)theNearestNeighbour
{
    self.currentBestPQ = [[JCPriorityQueue alloc] init];
    [self calculateNearestNeighbourWithCurrentNode:self.root];
    
    
    NSMutableArray* result = [[NSMutableArray alloc] init];
    while ([self.currentBestPQ count] > 1) {
        Node* node = [self.currentBestPQ pop];
        [result addObject:node.location];
        
        if([self.currentBestPQ count] == 1){
            NSLog(@"FINAL distance is :%f", [self distanceBetweenRecipeOne:node.location andRecipeTwo:self.searchPoint]);
        }
    }
    return result;
}

#pragma mark - utility methods

-(double)distanceBetweenCenterOfSphereAndParrentLocationPlaneOfNode:(Node*)node
{
    //sphere center is currentBest
    Node* parent = node.parent;
    double result = DBL_MAX;
    if(node && parent){
        NSUInteger detph = parent.depth;
        Ingredient* planeMakingIngredient = nil;
        if(parent.location && parent.location.ingredients && parent.location.ingredients.count > detph){
            planeMakingIngredient = [parent.location.ingredients objectAtIndex:detph];
        }
        if(planeMakingIngredient){
            double sphereCenterImportentIngredientValue = 0.0f;
            Node* currentWorst = self.currentBestPQ.first;
            for(Ingredient* i in currentWorst.location.ingredients){
                if([i.name isEqualToString:planeMakingIngredient.name]){
                    sphereCenterImportentIngredientValue = i.realValue;
                    break;
                }
            }
            //NSNumber* planeMakingIngredientNumber = planeMakingIngredient.realValue;
            double planeMakingIngredientValue = planeMakingIngredient.realValue;
            
            result = pow((planeMakingIngredientValue - sphereCenterImportentIngredientValue), 2.0f);
        }
    }
    return result;
}

-(void)checkIsNodeBetterThanCurrentBestAndUpdateIfNeeded:(Node*)newNode
{
    if([self.currentBestPQ count] == 1){
        double distToSearchPoint = [self distanceBetweenRecipeOne:newNode.location andRecipeTwo:self.searchPoint];
        [newNode setDistanceToSearchPoint:distToSearchPoint];
        [self.currentBestPQ addObject:newNode];
    }
    else{
        //check is current better than currentBest
        Node* currentWorstNode = (Node*)[self.currentBestPQ first];
        double distFromCurrentWorstToSearchPoint = currentWorstNode.distanceToSearchPoint;
        double distFromNewNodeAndSearchPoint = [self distanceBetweenRecipeOne:newNode.location andRecipeTwo:self.searchPoint];
        if([self.currentBestPQ count] < 11){
            //add it no matter its distance cause we do not have enough
            [newNode setDistanceToSearchPoint:distFromNewNodeAndSearchPoint];
            [self.currentBestPQ addObject:newNode];
        }
        else{
            if(distFromCurrentWorstToSearchPoint > distFromNewNodeAndSearchPoint){
                [self.currentBestPQ pop];
                [newNode setDistanceToSearchPoint:distFromNewNodeAndSearchPoint];
                [self.currentBestPQ addObject:newNode];
            }
        }
    }
}

-(void)calculateNearestNeighbourWithCurrentNode:(Node*)current
{
    if(current == nil){
        return;
    }
    if([current.location used] == YES){
        return;
    }
    
    [current.location setUsed:YES];
    
    //calculate where should we go
    Ingredient* importentIngredient = [self.searchPoint.ingredients objectAtIndex:current.depth];
    Recipe* currentLocation = current.location;
    Ingredient* ingredientInThisLocation = nil;
    for(Ingredient* i in currentLocation.ingredients){
        if([i.name isEqualToString:importentIngredient.name]){
            ingredientInThisLocation = i;
            break;
        }
    }
    double valueOfIngredientAtThisLocation = 0.0f;
    if(ingredientInThisLocation){
        valueOfIngredientAtThisLocation = ingredientInThisLocation.realValue;
    }
    //improve if needed
    [self checkIsNodeBetterThanCurrentBestAndUpdateIfNeeded:current];

    //check where should we go?
    if(importentIngredient.realValue >= valueOfIngredientAtThisLocation){
        
        //we should go right
        if(current.rightChild != nil){
            //we are not in child => go deeper
            [self calculateNearestNeighbourWithCurrentNode:current.rightChild];
        }
        
        //check is there intersection between parent Location Plane and search point hyper sphere
        double sphereRadius = [self distanceBetweenRecipeOne:current.location andRecipeTwo:self.searchPoint];
        double distanceBetweenShereCenterAndPlane = [self distanceBetweenCenterOfSphereAndParrentLocationPlaneOfNode:current];
        if(sphereRadius >= distanceBetweenShereCenterAndPlane){
            //there is intersection
            Node* destination = current.parent.leftChild;
            if(destination && destination.location){
                [self calculateNearestNeighbourWithCurrentNode:destination];
            }
        }
    }
    else{
        
        //we should go left
        if(current.leftChild != nil){
            //we are not in child => go deeper
            [self calculateNearestNeighbourWithCurrentNode:current.leftChild];
        }

        //check is there intersection between parent Location Plane and search point hyper sphere
        double sphereRadius = [self distanceBetweenRecipeOne:current.location andRecipeTwo:self.searchPoint];
        double distanceBetweenShereCenterAndPlane = [self distanceBetweenCenterOfSphereAndParrentLocationPlaneOfNode:current];
        if(sphereRadius >= distanceBetweenShereCenterAndPlane){
            //there is intersection
            Node* destination = current.parent.rightChild;
            if(destination && destination.location){
                [self calculateNearestNeighbourWithCurrentNode:destination];
            }
        }
    }
}

-(void)print
{
    [self.root print];
}

@end
