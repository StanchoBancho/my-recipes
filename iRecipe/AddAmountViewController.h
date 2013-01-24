//
//  AddAmountViewController.h
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/24/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddIngredientViewController.h"

@interface AddAmountViewController : UIViewController

@property (nonatomic, strong) NSString *selectedIngredient;
@property(nonatomic, weak) id<AddIngredientDelegate> delegate;

@end
