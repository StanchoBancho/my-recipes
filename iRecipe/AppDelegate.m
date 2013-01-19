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
    [self parseData];
    [self.window makeKeyAndVisible];
    return YES;
}


-(void)parseData
{
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString * documentsPath = [resourcePath stringByAppendingPathComponent:@"recipes"];
    
    NSError * error;
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    NSMutableArray* allRecipes = [[NSMutableArray alloc] init];
    for(NSString* txtFileName in directoryContents){
        NSString* txtFilePath = [txtFileName stringByDeletingPathExtension];
        [TXTParser parseTextFile:txtFilePath withCompletion:^(NSArray *result, NSError *error) {
            [allRecipes addObjectsFromArray:result];
        }];
    }
    SQLiteReader* dbReader = [[SQLiteReader alloc] init];
     
//    for(int i = 0; i < [allRecipes count]; i++){
//        Recipe* r = [allRecipes objectAtIndex:i];
//
////        [dbReader executeSQLStatement:@"INSERT INTO Recipe (name, howTo, time) VALUES ('%@', '%@', time)"];
////        NSMutableArray* lastRecipeIdRow = [dbReader readDBWithQuery:@"SELECT MAX(id) FROM Recipe"];
//        id lastRecipe = [[lastRecipe objectAtIndex:0] objectAtIndex:0];
//        
//        NSLog(@"------------------");
//        NSLog(@"%d, %@",i, r.name);
//        for(Ingredient* i in r.ingredients){
//            NSLog(@"ingredient: %@  ==  %f  -> %@ %@",i.amount, i.quantity.doubleValue, i.measure, i.name);
//        }
//    }
}
@end
