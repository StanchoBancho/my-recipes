//
//  IngredientCell.h
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/18/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IngredientCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* ingredient;
@property (nonatomic, strong) IBOutlet UILabel* quantity;
@property (nonatomic, strong) IBOutlet UILabel* measure;

@end
