//
//  AddIngredientViewController.h
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/18/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ingredient.h"

@protocol AddIngredientDelegate <NSObject>

-(void)dissmissWithIngredient:(Ingredient*)newIngredient;

@end

@interface AddIngredientViewController : UIViewController

@property(nonatomic, weak) id<AddIngredientDelegate> delegate;

@end
