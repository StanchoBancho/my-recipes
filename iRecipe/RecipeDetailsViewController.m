//
//  RecipeDetailsViewController.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/25/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "RecipeDetailsViewController.h"
#import "Ingredient.h"

@interface RecipeDetailsViewController ()

@end

@implementation RecipeDetailsViewController

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
    [self.navigationItem setTitle:@"Recipe Details"];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return self.recipe.ingredients.count;
        case 2:
            return 1;
        default:
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Name";
            break;
        case 1:
            return @"Ingredients";
            break;
        case 2:
            return @"Description";
            break;
        default:
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    }
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = self.recipe.name;
            break;
        case 1: {
            cell.textLabel.text = ((Ingredient*)[self.recipe.ingredients objectAtIndex:indexPath.row]).name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", ((Ingredient*)[self.recipe.ingredients objectAtIndex:indexPath.row]).quantity, ((Ingredient*)[self.recipe.ingredients objectAtIndex:indexPath.row]).measure];
            break;
        }
        case 2: {
            cell.textLabel.text = self.recipe.howTo;
            cell.textLabel.numberOfLines = 0;
            NSLog(@"%@", cell.textLabel.font);
        }
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        CGSize constraint = CGSizeMake(280.f, MAXFLOAT);
        CGSize size = [self.recipe.howTo sizeWithFont:[UIFont boldSystemFontOfSize:19.f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        return size.height;
    }
    return 44.f;
}
#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
