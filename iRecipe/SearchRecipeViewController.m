//
//  ViewController.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 12/5/12.
//  Copyright (c) 2012 Stanimir Nikolov. All rights reserved.
//

#import "SearchRecipeViewController.h"
#import "SuggestFooterView.h"
#import "IngredientCell.h"
#import "Ingredient.h"
#import "AddIngredientViewController.h"

@interface SearchRecipeViewController ()<UITableViewDataSource, UITabBarDelegate>

@property (nonatomic, strong) SuggestFooterView* footerView;
@property (nonatomic, strong) IBOutlet UITableView* ingredientsTableView;
@property (nonatomic, strong) NSMutableArray* ingredients;
@end

static NSString* ingredientCellName = @"IngredientCell";
static NSString* addIngredientCellName = @"AddIngredientCell";

@implementation SearchRecipeViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.ingredients = [NSMutableArray array];
        for(int i= 0; i < 10; i++){
            Ingredient* oneIngredient = [[Ingredient alloc] initWithName:@"Chubrika" amount:@"100" andMeasure:@"kila"];
            [self.ingredients addObject:oneIngredient];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:addButton];
    [self.navigationItem setTitle:@"Ingredients"];
    
    [self.ingredientsTableView setEditing:YES];
    
    UINib* addCellNib = [UINib nibWithNibName:@"AddIngredientCell" bundle:[NSBundle mainBundle]];
    [self.ingredientsTableView registerNib:addCellNib forCellReuseIdentifier:addIngredientCellName];
    UINib* cellNib = [UINib nibWithNibName:@"IngredientCell" bundle:[NSBundle mainBundle]];
    [self.ingredientsTableView registerNib:cellNib forCellReuseIdentifier:ingredientCellName];
    
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"SuggestFooterView" owner:self options:nil];
    self.footerView = [nibObjects objectAtIndex:0];

    [self.ingredientsTableView reloadData];
    
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction)addButtonPressed:(id)sender
{
    
}


#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.ingredients count]+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        UITableViewCell* addIngredientCell = [tableView dequeueReusableCellWithIdentifier:addIngredientCellName];
        [addIngredientCell setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [addIngredientCell setShouldIndentWhileEditing:YES];
        return addIngredientCell;
    }
    else{
        IngredientCell* cell = [tableView dequeueReusableCellWithIdentifier:ingredientCellName];
        Ingredient* currentIngredient = [self.ingredients objectAtIndex:indexPath.row-1];
        [cell.ingredient setText:currentIngredient.name];
        [cell.quantity setText:currentIngredient.amount];
        [cell.measure setText:currentIngredient.measure];
        [cell setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setShouldIndentWhileEditing:YES];
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if([self.ingredients count] == 0){
        return nil;
    }
    else{
        return self.footerView;
    }
}

#pragma mark - UITableView Delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return UITableViewCellEditingStyleInsert;
    }
    else{
        return UITableViewCellEditingStyleDelete;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return 42.0;
    }
    else{
        return 72.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if([self.ingredients count] == 0){
        return 0.0f;
    }
    else{
        return self.footerView.frame.size.height;
    }
}



@end
