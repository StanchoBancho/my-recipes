//
//  AddIngredientCell.h
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/18/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddIngredientCell : UITableViewCell

@property(nonatomic, strong) IBOutlet NSLayoutConstraint* cellLabelHSpaceConstraint;
@property(nonatomic, strong) IBOutlet UILabel* addIngredientLabel;

@end
