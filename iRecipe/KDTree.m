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

@property(nonatomic, weak)id<ProgresVisualizer>delegate;

@end

@implementation KDTree

-(NSInteger)distanceBetweenRecipeOne:(Recipe*)recipeOne andRecipeTwo:(Recipe*)recipeTwo
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
            value1 = one.realValue / one.maxRealValue;
        }
        
        double value2 = 0.0f;
        if(two){
            value2 = two.realValue / two.maxRealValue;
        }
//        if(one && two)
//        {
            result += pow((value1 - value2), 2.0f);
//        }
    }
    result *= 10000;
    return (NSInteger)floor(result);
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
        
        //setup pid, quantity, measure & realValue
        NSString* ingredientFk = [iRelation objectAtIndex:1];
        [i setPid:ingredientFk];
        
        NSString* quantityString = [iRelation objectAtIndex:3];
        double quantity = [quantityString doubleValue];
        NSNumber* quantityNumber = [NSNumber numberWithDouble:quantity];
        [i setQuantity:quantityNumber];
        
        NSString* measure = [iRelation objectAtIndex:4];
        [i setMeasure:measure];
        
        NSString* realValueString = [NSString stringWithFormat:@"%.2f", [[iRelation objectAtIndex:5] doubleValue]];
        double realValue = [realValueString doubleValue];
        [i setRealValue:realValue];
        
        //get the name of ingredient
        NSString* selectIngredientName = [NSString stringWithFormat:@"SELECT name FROM Ingredient WHERE id = %@",i.pid];
        NSMutableArray* ingredientNameResult = [self.dbReader readDBWithQuery:selectIngredientName];
        NSString* ingredientName = [[ingredientNameResult objectAtIndex:0] objectAtIndex:0];
        [i setName:ingredientName];
        
        //setup maxRealValue
        for(Ingredient* existingIngredient in self.searchPoint.ingredients){
            if([i.name isEqualToString:existingIngredient.name]){
                i.maxRealValue = existingIngredient.maxRealValue;
                break;
            }
        }
        
        
//        NSString* posibleMaxValueStatement = [NSString stringWithFormat:@"SELECT MAX(realValue) FROM Relation WHERE IngredientFk=%@", i.pid];
//        NSMutableArray* resultFromMaxValueSelect = [self.dbReader readDBWithQuery:posibleMaxValueStatement];
//        NSString* maxRealValueString = [NSString stringWithFormat:@"%.2f", [[[resultFromMaxValueSelect objectAtIndex:0] objectAtIndex:0] doubleValue]];
//        double maxRealValue = [maxRealValueString doubleValue];
//        [i setMaxRealValue:maxRealValue];
        
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
    [self.delegate theProgressOfTheTaskIs:0.1f];
    //this task will move the progress from 0.1f to 0,9f
    int allRecipes = [recipeIds count];
    int currentReadRecipes = 0;

    for(NSMutableArray* ids in recipeIds){
        currentReadRecipes++;
        if(currentReadRecipes % 10){
            float theProgress = 0.7 * ((float)currentReadRecipes / (float)allRecipes);
            [self.delegate theProgressOfTheTaskIs:theProgress];
        }
        NSString* recipeId = [ids objectAtIndex:0];
        Recipe* recipe = [self populateRecipeWithId:recipeId];
        [result addObject:recipe];
    }
    [self.delegate theProgressOfTheTaskIs:0.81];
    return result;
}

-(id)initWithIngredients:(NSMutableArray*)ingredients andDelegate: (id<ProgresVisualizer>)delegate
{
    self = [super init];
    if(self){
        self.delegate = delegate;
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
{   NSInteger minDistance = INT_MAX;
    Recipe* result = nil;
    for(Recipe* r in self.allRecipes){
        NSInteger curretnDisttance = [self distanceBetweenRecipeOne:r andRecipeTwo:self.searchPoint];
        //NSLog(@"distance is :%f",curretnDisttance);
        if(curretnDisttance < minDistance){
            minDistance = curretnDisttance;
            result = r;
        }
    }
    [self.delegate theProgressOfTheTaskIs:1.0f];
    NSLog(@"FINAL distance is :%d" , [self distanceBetweenRecipeOne:result andRecipeTwo:self.searchPoint] );
    return result;
}


-(NSMutableArray*)theNearestNeighbour
{
    self.currentBestPQ = [[JCPriorityQueue alloc] init];
    [self calculateNearestNeighbourWithCurrentNode:self.root];
    NSMutableArray* result = [[NSMutableArray alloc] init];
    while ([self.currentBestPQ count] > 1) {
        Node* node = [self.currentBestPQ pop];
        [result addObject:node];
    }
    [self.delegate theProgressOfTheTaskIs:0.95f];
    return result;
}

#pragma mark - utility methods

-(NSInteger)distanceBetweenCenterOfSphereAndParrentLocationPlaneOfNode:(Node*)node
{
    Node* parent = node.parent;   
    if(node && parent){
        double result = 0.0f;
        NSUInteger detph = parent.depth;
      
        //get the sphere center importent ingredient
        Ingredient* sphereImportantIgredient = (Ingredient*)[[self.searchPoint ingredients] objectAtIndex:detph];
        double sphereCenterImportentIngredientValue = [sphereImportantIgredient realValue] / [sphereImportantIgredient maxRealValue];

        //get the plane importent ingredient
        double planeImportentIngredientValue = 0.0f;
        Ingredient* planeImportantIngredient = parent.igredientForThisDepth;
        if(planeImportantIngredient){
            planeImportentIngredientValue = [planeImportantIngredient realValue] / [planeImportantIngredient maxRealValue];
        }
        
        result = pow((planeImportentIngredientValue - sphereCenterImportentIngredientValue), 2.0f);
        result *= 10000;
        return (NSInteger)floor(result);
    }
    else{
        //if there is no parent return negative number to check the other hyper plane
        return -1;
    }
}

-(void)updateCurrentBestPQWithNode:(Node*)newNode
{
    if([self.currentBestPQ count] == 1){
        NSInteger distToSearchPoint = [self distanceBetweenRecipeOne:newNode.location andRecipeTwo:self.searchPoint];
        if(distToSearchPoint < 0)
        {
            NSLog(@"FAck");
        }
        [newNode setDistanceToSearchPoint:distToSearchPoint];
        [self.currentBestPQ addObject:newNode];
    }
    else{
        //check is current better than currentWorst
        Node* currentWorstNode = (Node*)[self.currentBestPQ first];
        NSInteger distFromCurrentWorstToSearchPoint = currentWorstNode.distanceToSearchPoint;
        NSInteger distFromNewNodeAndSearchPoint = [self distanceBetweenRecipeOne:newNode.location andRecipeTwo:self.searchPoint];
        [newNode setDistanceToSearchPoint:distFromNewNodeAndSearchPoint];
        if(distFromNewNodeAndSearchPoint < 0)
        {
            NSLog(@"FAck");
        }
        if([self.currentBestPQ count] < 11){
            //add it no matter its distance cause we do not have enough
            [self.currentBestPQ addObject:newNode];
        }
        else{
            if(distFromCurrentWorstToSearchPoint > distFromNewNodeAndSearchPoint){
                [self.currentBestPQ pop];
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
  //  NSLog(@"Current Location name is: %@",current.location.name);
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
    [self updateCurrentBestPQWithNode:current];
    
    //check where should we go?
    if(importentIngredient.realValue >= valueOfIngredientAtThisLocation){
        
        //we should go right
        if(current.rightChild != nil){
            //we are not in child => go deeper
            [self calculateNearestNeighbourWithCurrentNode:current.rightChild];
        }
        
        //check is there intersection between parent Location Plane and search point hyper sphere
        NSInteger sphereRadius = [self distanceBetweenRecipeOne:current.location andRecipeTwo:self.searchPoint];
        NSInteger distanceBetweenShereCenterAndPlane = [self distanceBetweenCenterOfSphereAndParrentLocationPlaneOfNode:current];
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
        NSInteger sphereRadius = [self distanceBetweenRecipeOne:current.location andRecipeTwo:self.searchPoint];
        NSInteger distanceBetweenShereCenterAndPlane = [self distanceBetweenCenterOfSphereAndParrentLocationPlaneOfNode:current];
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
