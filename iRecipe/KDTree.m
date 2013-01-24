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
@interface KDTree()

@property(nonatomic, strong) SQLiteReader* dbReader;

@end

@implementation KDTree

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
        
        NSString* realValueString = [iRelation objectAtIndex:5];
        double realValue = [realValueString doubleValue];
        NSNumber* realValueNumber = [NSNumber numberWithDouble:realValue];
        [i setQuantity:realValueNumber];
        
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

-(NSMutableArray*)allRecipesThatMatchThisIngredients:(NSMutableArray*)ingredients
{
    //select desired recipe ids
    NSMutableString* selectRecipeIdStatement =[NSMutableString stringWithFormat:@"SELECT DISTINCT recipeFk FROM Relation WHERE "];
    for (int i = 0; i < ingredients.count; i++) {
        Ingredient* ingredient = [ingredients objectAtIndex:i];
        [selectRecipeIdStatement appendFormat:@"ingredientFk = %@",ingredient.pid];
        if(i != [ingredients count] - 1){
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
        self.dbReader = [[SQLiteReader alloc] init];
        NSMutableArray* allNeedRecipes = [self allRecipesThatMatchThisIngredients:ingredients];
        NSLog(@"recipe count:%d",[allNeedRecipes count]);
        Node* root = [[Node alloc] initWithRecipes:allNeedRecipes andIngredients:ingredients andDepth:0];
        self.root = root;
    }
    return self;
}

-(void)print
{
    [self.root print];
}

@end
