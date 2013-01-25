//
//  ShowRecipesViewController.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/25/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "ShowRecipesViewController.h"
#import "Recipe.h"
#import "RecipeDetailsViewController.h"

@interface ShowRecipesViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation ShowRecipesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    cell.textLabel.text = ((Recipe*)[self.datasource objectAtIndex:indexPath.row]).name;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RecipeDetailsViewController *recipeVC = [[RecipeDetailsViewController alloc] initWithNibName:@"RecipeDetailsViewController" bundle:nil];
    recipeVC.recipe = [self.datasource objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:recipeVC animated:YES];
}


@end
