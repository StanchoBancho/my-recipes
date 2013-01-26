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
#import "ShowRecipesViewController.h"
#import "UIView+Additions.h"

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
    
    [self.ingredientsTableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self.ingredients count] > 0){
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"SuggestFooterView" owner:self options:nil];
        self.footerView = [nibObjects objectAtIndex:0];
        [self.footerView.sugestButton addTarget:self action:@selector(suggestButtonPressed:) forControlEvents:UIControlEventTouchDown];
    }
[self.ingredientsTableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Action methods

-(IBAction)suggestButtonPressed:(id)sender
{
    [self.ingredientsTableView setUserInteractionEnabled:NO];
    
    UIView* loadingView = [UIView presentPositiveNotifyingViewWithTitle:@"Suggesting..."onView:self.view];
    [self.view addSubview:loadingView];
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
        @autoreleasepool {
            NSTimeInterval timeNeededForKDTreeInit = 0.0f;
            //suggest with k-d tree
            NSDate* startDate = [NSDate date];
            KDTree* aTree = [[KDTree alloc] initWithIngredients:self.ingredients];
            NSDate* endDate = [NSDate date];
            timeNeededForKDTreeInit = [endDate timeIntervalSinceDate:startDate];
            NSLog(@"--------------------------");
            NSLog(@"Time For KD Tree creation is: %f", timeNeededForKDTreeInit);
            startDate = [NSDate date];
            NSMutableArray* allNearestNeighBours = [aTree theNearestNeighbour];
            endDate = [NSDate date];
            timeNeededForKDTreeInit = [endDate timeIntervalSinceDate:startDate];
            NSLog(@"Time for search is: %f", timeNeededForKDTreeInit);
            NSMutableArray* allRecipes = [[NSMutableArray alloc] initWithCapacity:[allNearestNeighBours count]];
            for(Node* nearestNeighBour in allNearestNeighBours){
                NSLog(@"A near newighbour With Distance:%d is : %@",nearestNeighBour.distanceToSearchPoint,nearestNeighBour.location.name);
                [allRecipes insertObject:nearestNeighBour.location atIndex:0];
                
                //            NSLog(@"Ingredients:");
                //            for(Ingredient* i in nearestNeighBour.location.ingredients){
                //                NSLog(@"%@  %f",i.name, i.realValue);
                //            }
            }
            
            NSLog(@"--------------------------");
            startDate = [NSDate date];
            Recipe* trivialAnswer = [aTree trivialSearch];
            endDate = [NSDate date];
            timeNeededForKDTreeInit = [endDate timeIntervalSinceDate:startDate];
            NSLog(@"Total time For trivial search: %f", timeNeededForKDTreeInit);
            NSLog(@"NEARESH NEIGHBOUR IS : %@",trivialAnswer.name);
            //        NSLog(@"Ingredients:");
            //        for(Ingredient* i in trivialAnswer.ingredients){
            //            NSLog(@"%@  %f",i.name, i.realValue);
            //        }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //present the result vc
                ShowRecipesViewController *recipesVC = [[ShowRecipesViewController alloc] initWithNibName:@"ShowRecipesViewController" bundle:nil];
                recipesVC.datasource = allRecipes;
                [loadingView removeFromSuperview];
                
                [UIView  beginAnimations: @"Showinfo"context: nil];
                [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDuration:1.f];
                [self.ingredientsTableView setUserInteractionEnabled:YES];
                [self.navigationController pushViewController:recipesVC animated:NO];
                [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO];
                [UIView commitAnimations];
            });
        }
    });
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.ingredients count]+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        [cell.quantity setText:[NSString stringWithFormat:@"%.2f", currentIngredient.realValue]];
        [cell.measure setText:currentIngredient.measure];
        [cell setEditingAccessoryType:UITableViewCellAccessoryNone];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self.ingredients removeObjectAtIndex:indexPath.row - 1];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        if([self.ingredients count] == 0){
            [tableView reloadData];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0){
        if([self.ingredients count] == 10){
            UIAlertView* tooMuchRecipeAllertView = [[UIAlertView alloc] initWithTitle:@"Too much ingredients!" message:@"Sorry but our app is still not very smart... So it cannot suggest with more than 10 ingredients." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [tooMuchRecipeAllertView show];
        }
        else{
            AddIngredientViewController* addIngredientVC = [[AddIngredientViewController alloc] initWithNibName:@"AddIngredientViewController" bundle:[NSBundle mainBundle]];
            [addIngredientVC setDelegate:self];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addIngredientVC];
            [navController.navigationBar setBarStyle:UIBarStyleBlack];
            [self.navigationController presentViewController:navController animated:YES completion:nil];
        }
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
