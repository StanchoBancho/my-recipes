//
//  ViewController.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 12/5/12.
//  Copyright (c) 2012 Stanimir Nikolov. All rights reserved.
//

#import "ViewController.h"
#import "TXTParser.h"
#import "Recipe.h"
#import "Ingredient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [TXTParser parseTextFile:@"Fish" withCompletion:^(NSArray *result, NSError *error) {
        for(int i = 0; i < [result count]; i++){
            Recipe* r = [result objectAtIndex:i];
            NSLog(@"------------------");
            NSLog(@"%d, %@",i, r.name);
            for(Ingredient* i in r.ingredients){
                NSLog(@"ingredient: %@ %@ %@",i.amount, i.measure, i.name);
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
