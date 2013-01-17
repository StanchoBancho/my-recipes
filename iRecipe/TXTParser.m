//
//  TXTParser.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 12/5/12.
//  Copyright (c) 2012 Stanimir Nikolov. All rights reserved.
//

#import "TXTParser.h"
#import "Recipe.h"
#import "Ingredient.h"

@implementation TXTParser

+ (NSString*)contentOfTextFile:(NSString*)file {
    NSString *textFilePath = [[NSBundle mainBundle] pathForResource:file ofType:@"txt"];
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:textFilePath encoding:NSUTF8StringEncoding error:&error];
    if (error) return nil;
    return content;
}

+ (void)parseTextFile:(NSString*)file withCompletion:(void(^)(NSArray *result, NSError *error))completion {
    NSString *content = [self contentOfTextFile:file];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    if (content) {
        NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        int i = 0;
        while (i < lines.count) {
            NSString *line = [lines objectAtIndex:i];
            
            if ([line rangeOfString:@"Exported from MasterCook"].location != NSNotFound) {
                //new recipe
                Recipe *recipe = [[Recipe alloc] init];
                recipe.category = file;
                
                //get recipe name
                line = [lines objectAtIndex:++i];
                while ([line isEqualToString:@""]) {
                    line = [lines objectAtIndex:++i];
                }
                NSString *name = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                recipe.name = name;
                
                //get ingredients
                line = [lines objectAtIndex:++i];
                while ([line isEqualToString:@""] || [line rangeOfString:@"Amount"].location == NSNotFound) {
                    line = [lines objectAtIndex:++i];
                }
                line = [lines objectAtIndex:++i];
                while ([line isEqualToString:@""] || [line rangeOfString:@"---"].location != NSNotFound) {
                    line = [lines objectAtIndex:++i];
                }
                NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
                NSMutableArray *ingrTempArr = [[NSMutableArray alloc] init];
                while (![line isEqualToString:@""]) {
                    NSString* quantityString = [[line substringToIndex:8] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if([quantityString isEqualToString:@""]){
                        quantityString = @"1";
                    }
                    NSString* measureString = [[line substringWithRange:NSMakeRange(8, 14)]  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if([measureString isEqualToString:@""]){
                        measureString = @"default measure";
                    }
                    NSString* ingredientName = [[line substringWithRange:NSMakeRange(24, line.length-24)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    
                        Ingredient *ingredients = [[Ingredient alloc] initWithName:ingredientName amount:quantityString andMeasure:measureString];
                        [ingrTempArr addObject:ingredients];
                    
                    i+=2;
                    line = [lines objectAtIndex:i];
                }
                recipe.ingredients = [[NSArray alloc] initWithArray:ingrTempArr];
                [result addObject:recipe];
                
            } else {
                i++;
            }
        }
        
        NSError *error;
        completion(result, error);
    }
}

@end
