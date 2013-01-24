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
#import "KDTree.h"

@interface SearchRecipeViewController ()<UITableViewDataSource, UITabBarDelegate, AddIngredientDelegate>

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
        [self setView:[[[NSBundle mainBundle] loadNibNamed:@"SearchRecipeViewController" owner:self options:nil] objectAtIndex:0]];
        self.ingredients = [NSMutableArray array];
        }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [self.navigationItem setTitle:@"Ingredients"];
    
    [self.ingredientsTableView setEditing:YES];
    
    UINib* addCellNib = [UINib nibWithNibName:@"AddIngredientCell" bundle:[NSBundle mainBundle]];
    [self.ingredientsTableView registerNib:addCellNib forCellReuseIdentifier:addIngredientCellName];
    UINib* cellNib = [UINib nibWithNibName:@"IngredientCell" bundle:[NSBundle mainBundle]];
    [self.ingredientsTableView registerNib:cellNib forCellReuseIdentifier:ingredientCellName];
    
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"SuggestFooterView" owner:self options:nil];
    self.footerView = [nibObjects objectAtIndex:0];
    [self.footerView.sugestButton addTarget:self action:@selector(suggestButtonPressed:) forControlEvents:UIControlEventTouchDown];
    
    [self.ingredientsTableView reloadData];
    
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Action methods 

-(IBAction)suggestButtonPressed:(id)sender
{
    NSTimeInterval timeNeededForKDTreeInit = 0.0f;
    NSDate* startDate = [NSDate date];
    KDTree* aTree = [[KDTree alloc] initWithIngredients:self.ingredients];
    NSDate* endDate = [NSDate date];
    timeNeededForKDTreeInit = [endDate timeIntervalSinceDate:startDate];
    NSLog(@"Time For KD Tree creation is: %f", timeNeededForKDTreeInit);
    [aTree print];
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
        [cell.quantity setText:[currentIngredient.quantity stringValue]];
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
    return 70.0;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0){
        AddIngredientViewController* addIngredientVC = [[AddIngredientViewController alloc] initWithNibName:@"AddIngredientViewController" bundle:[NSBundle mainBundle]];
        [addIngredientVC setDelegate:self];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addIngredientVC];

        [self.navigationController presentViewController:navController animated:YES completion:nil];
    }
}

#pragma mark - AddIngredientDelegate

-(void)dissmissWithIngredient:(Ingredient*)newIngredient
{
    [[self ingredients] addObject:newIngredient];
    [[self ingredientsTableView] reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
