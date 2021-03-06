//
//  AppDelegate.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 12/5/12.
//  Copyright (c) 2012 Stanimir Nikolov. All rights reserved.
//

#import "AppDelegate.h"
#import "TXTParser.h"
#import "Recipe.h"
#import "Ingredient.h"
#import "SQLiteReader.h"

@implementation AppDelegate

static int maxIngredients = 0;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self copyDBFromBundleToDocumentsIfNeeded];
//    [self secondParseData];
    return YES;
}
#pragma mark - Use Already existing Data Base 

-(void)copyDBFromBundleToDocumentsIfNeeded
{
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataBasePath = [documentsDirectory stringByAppendingPathComponent:kDBName];
    BOOL isExisting = [fileManager fileExistsAtPath:dataBasePath];
    if(!isExisting){
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"RecipeDB" ofType:@"sqlite"];
        [fileManager copyItemAtPath:bundlePath toPath: dataBasePath error:&error];
    }
}

#pragma mark - SECOND WAY OF Parsing DATA BASE

-(void)secondParseData
{
    //create the data base
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataBasePath = [documentsDirectory stringByAppendingPathComponent:kDBName];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BlankRecipeDB" ofType:@"sqlite"];
    [fileManager removeItemAtPath:dataBasePath error:&error];
    
    [fileManager copyItemAtPath:bundlePath toPath: dataBasePath error:&error];
    
    //parse the data
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString * documentsPath = [resourcePath stringByAppendingPathComponent:@"recipes"];
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    NSMutableArray* allRecipes = [[NSMutableArray alloc] init];
    for(NSString* txtFileName in directoryContents){
        NSString* txtFilePath = [txtFileName stringByDeletingPathExtension];
        [TXTParser parseTextFile:txtFilePath withCompletion:^(NSArray *result, NSError *error) {
            [allRecipes addObjectsFromArray:result];
        }];
    }
    //put the data in the sqlite file
    [self putRecipesInDataBase:allRecipes];
}

-(void)putRecipesInDataBase:(NSMutableArray*)allRecipes
{
    SQLiteReader* dbReader = [[SQLiteReader alloc] init];
    for(int i = 0; i < [allRecipes count]; i++){
        Recipe* r = [allRecipes objectAtIndex:i];
        if([r.ingredients count] > maxIngredients){
            maxIngredients = [r.ingredients count];
        }
        //insert recipe
        NSString* insertStatement = [NSString stringWithFormat:@"INSERT INTO Recipe (name, howTo, time, category) VALUES ('%@', '%@', %f, '%@');",r.name, r.howTo, [r.preparationTime doubleValue], r.category];
        BOOL resultOfAddRecipe = [dbReader executeSQLStatement:insertStatement];
        if(resultOfAddRecipe){
            NSMutableArray* lastRecipeIdRaw = [dbReader readDBWithQuery:@"SELECT MAX(id) FROM Recipe"];
            NSString* recipeId = [[lastRecipeIdRaw objectAtIndex:0] objectAtIndex:0];
            for(Ingredient* i in r.ingredients){
                NSString* ingredientId = [self putIngredient:i ifNeededAndReadItsId:dbReader];
                if(ingredientId){
                    NSString* insertSetStatement = [NSString stringWithFormat:@"INSERT INTO 'Relation' (ingredientFk, recipeFk, quantity, measure, realValue) VALUES (%d, %d, %f, '%@', %f)",[ingredientId intValue], [recipeId intValue], [i.quantity floatValue], i.measure, i.realValue];
                    
                    //NSLog(@"real value - %@", [NSString stringWithFormat:@"%.2f",i.realValue]);
//                    NSString* insertSetStatement = [NSString stringWithFormat:@"INSERT INTO 'Relation' (ingredientFk, recipeFk, quantity, measure, realValue) VALUES (%d, %d, %f, '%@', 130.58)",[ingredientId intValue], [recipeId intValue], [i.quantity floatValue], i.measure];

                    BOOL resultOfAddInSet = [dbReader executeSQLStatement:insertSetStatement];
                    if (!resultOfAddInSet) {
                        NSLog(@"losho");
                    }
                }
                
            }
        }
    }
}

-(NSString*)putIngredient:(Ingredient*) ingredient ifNeededAndReadItsId:(SQLiteReader*)dbReader
{
    NSString* result = nil;
    
    //check is there such ingredient
    NSString* checkForThisIngredientStatement = [NSString stringWithFormat:@"SELECT * FROM Ingredient WHERE name = '%@'",ingredient.name];
    NSMutableArray* ingredientCheck = [dbReader readDBWithQuery:checkForThisIngredientStatement];
    BOOL isThisIngredientExisting = [ingredientCheck count] > 0;
    if(isThisIngredientExisting){
        NSMutableArray* ingredient = [ingredientCheck objectAtIndex:0];
        isThisIngredientExisting = ingredient && [ingredient count] == 2;
    }
    if(!isThisIngredientExisting){
        //there is NO such ingredient
        NSString* insertIngredientStatement = [NSString stringWithFormat:@"INSERT INTO Ingredient (name) VALUES ('%@')",ingredient.name];
        BOOL resultOfAddIngredient = [dbReader executeSQLStatement:insertIngredientStatement];
        if(resultOfAddIngredient){
            NSMutableArray* lastRecipeIdRaw = [dbReader readDBWithQuery:@"SELECT MAX(id) FROM Ingredient"];
            if([lastRecipeIdRaw count] > 0 && [[lastRecipeIdRaw objectAtIndex:0] count] > 0){
                result = [[lastRecipeIdRaw objectAtIndex:0] objectAtIndex:0];
            }
        }
    }
    else{
        //there is such ingredient
        result = [[ingredientCheck objectAtIndex:0] objectAtIndex:0];
    }
    return result;
}


@end
