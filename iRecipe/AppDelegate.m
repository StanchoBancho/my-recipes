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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [self parseData];
    return YES;
}


-(void)parseData
{
    //create the data base
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataBasePath = [documentsDirectory stringByAppendingPathComponent:kDBName];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"RecipeDB" ofType:@"sqlite"];
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
    SQLiteReader* dbReader = [[SQLiteReader alloc] init];
    for(int i = 0; i < [allRecipes count]; i++){
        Recipe* r = [allRecipes objectAtIndex:i];
        //insert recipe
        NSString* insertStatement = [NSString stringWithFormat:@"INSERT INTO Recipe (name, howTo, time, category) VALUES ('%@', '%@', %f, '%@');",r.name, r.howTo, [r.preparationTime doubleValue], r.category];
        BOOL result = [dbReader executeSQLStatement:insertStatement];
        if(result){
            NSMutableArray* lastRecipeIdRaw = [dbReader readDBWithQuery:@"SELECT MAX(id) FROM Recipe"];
            NSString* lastRecipeId = [[lastRecipeIdRaw objectAtIndex:0] objectAtIndex:0];
            for(Ingredient* i in r.ingredients){
               //check is there such ingredient
                NSString* checkForThisIngredientStatement = [NSString stringWithFormat:@"SELECT * FROM Ingredient WHERE name = '%@' AND measure = '%@'",i.name, i.measure];
                NSMutableArray* ingredientCheck = [dbReader readDBWithQuery:checkForThisIngredientStatement];
                BOOL isThisIngredientExisting = [ingredientCheck count] > 0;
                if(isThisIngredientExisting){
                    NSMutableArray* ingredient = [ingredientCheck objectAtIndex:0];
                    isThisIngredientExisting = [ingredient count] == 3;
                }
                NSString* ingredientId = nil;
                if(!isThisIngredientExisting){
                    //there is NO such ingredient
                    NSString* insertIngredientStatement = [NSString stringWithFormat:@"INSERT INTO Ingredient (name, measure) VALUES ('%@', '%@')",i.name, i.measure];
                    BOOL resultOfAddIngredient = [dbReader executeSQLStatement:insertIngredientStatement];
                    NSMutableArray* lastRecipeIdRaw = [dbReader readDBWithQuery:@"SELECT MAX(id) FROM Ingredient"];
                    ingredientId = [[lastRecipeIdRaw objectAtIndex:0] objectAtIndex:0];
                }
                else{
                    //there is such ingredient
                    ingredientId = [[ingredientCheck objectAtIndex:0] objectAtIndex:0];
                }
            
            }
        }
    }
}
@end
