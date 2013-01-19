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

static int screwedRecipes = 0;


@implementation TXTParser

+ (NSString*)contentOfTextFile:(NSString*)file {
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString * documentsPath = [resourcePath stringByAppendingPathComponent:@"recipes"];
    NSString * txtFile = [NSString stringWithFormat:@"%@.txt",file];
    NSString * filePath = [documentsPath stringByAppendingPathComponent:txtFile];
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSISOLatin1StringEncoding error:&error];
    if (error)
        return nil;
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
                line = [lines objectAtIndex:++i];
                
                //get prepartation time
                while ([line isEqualToString:@""] || [line rangeOfString:@"Preparation Time :"].location == NSNotFound) {
                    line = [lines objectAtIndex:++i];
                }
                NSRange rangeOfFirstColumn = [line rangeOfString:@"e :"];
                NSString * theNumberString = [[line substringFromIndex:rangeOfFirstColumn.location+3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSRange rangeOfSecondColumn = [theNumberString rangeOfString:@":"];
                NSString* firstPart = [theNumberString substringToIndex:rangeOfSecondColumn.location];
                NSString* secondPart = [theNumberString substringFromIndex:(rangeOfSecondColumn.location+1)];
                double hours = [firstPart doubleValue];
                double minutes = [secondPart doubleValue];
                double preparationTime = hours * 60.0 + minutes;
                NSNumber* time = [NSNumber numberWithDouble:preparationTime];
                [recipe setPreparationTime:time];
                
                
                //get ingredients
                while ([line isEqualToString:@""] || [line rangeOfString:@"Amount"].location == NSNotFound) {
                    line = [lines objectAtIndex:++i];
                }
                line = [lines objectAtIndex:++i];
                while ([line isEqualToString:@""] || [line rangeOfString:@"---"].location != NSNotFound) {
                    line = [lines objectAtIndex:++i];
                }
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
                    
                    if([measureString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"123456789/"]].location != NSNotFound){
                        //  NSLog(@"Preebana recepta:%d  %@ | %@ | %@", screwedRecipes, quantityString, measureString, ingredientName);
                        screwedRecipes ++;
                    }
                    Ingredient *ingredients = [[Ingredient alloc] initWithName:ingredientName amount:quantityString andMeasure:measureString];
                    [ingrTempArr addObject:ingredients];
                    i+=2;
                    line = [lines objectAtIndex:i];
                }
                recipe.ingredients = [[NSArray alloc] initWithArray:ingrTempArr];
                
                //get how to
                NSMutableString* howTo = [[NSMutableString alloc] init];
                while ([line rangeOfString:@"- - - - - - - - - - - - - - - - - - -"].location == NSNotFound) {
                    [howTo appendString:line];
                    i+=2;
                    line = [lines objectAtIndex:i];
                }
                NSString* finalHowTo = [howTo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [recipe setHowTo:finalHowTo];
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
