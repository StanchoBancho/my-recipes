//
//  AddIngredientViewController.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/18/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "AddIngredientViewController.h"
#import "SQLiteReader.h"
#import "AddAmountViewController.h"

@interface AddIngredientViewController ()<UITextFieldDelegate>

@property(nonatomic, strong) SQLiteReader* dbReader;

@property (strong, nonatomic) IBOutlet UITableView *ingredientsTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *ingredientsSearchBar;

@property (nonatomic, strong) NSMutableArray *allIngredients;
@property (nonatomic, strong) NSMutableArray *filteredIngredients;

@property(nonatomic, copy) NSString* name;
@property(nonatomic, strong) NSNumber* quantity;

@end

@implementation AddIngredientViewController

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
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    self.dbReader = [[SQLiteReader alloc] init];
    NSString* selectStatement = [NSString stringWithFormat:@"SELECT name FROM Ingredient ORDER BY name"];
    self.allIngredients = [[NSMutableArray alloc] initWithArray:[self.dbReader readDBWithQuery:selectStatement]];
    self.filteredIngredients = [[NSMutableArray alloc] initWithArray:self.allIngredients];
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        self.filteredIngredients = [[NSMutableArray alloc] initWithArray:self.allIngredients];
        [self.ingredientsTableView reloadData];
    } else {
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (NSArray* s in self.allIngredients) {
            if ([[[s lastObject] lowercaseString] hasPrefix:[searchText lowercaseString]]) {
                [temp addObject:s];
            }
        }
        self.filteredIngredients = [[NSMutableArray alloc] initWithArray:temp];
        [self.ingredientsTableView reloadData];
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredIngredients.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [[self.filteredIngredients objectAtIndex:indexPath.row] lastObject];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AddAmountViewController *addAmountVC = [[AddAmountViewController alloc] initWithNibName:@"AddAmountViewController" bundle:nil];
    addAmountVC.selectedIngredient = [[self.filteredIngredients objectAtIndex:indexPath.row] lastObject];
    addAmountVC.delegate = self.delegate;
    [self.navigationController pushViewController:addAmountVC animated:YES];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(textField.tag == 1){
        self.name = textField.text;
    }
    else if(textField.tag == 2){
        double value = [textField.text doubleValue];
        self.quantity =[NSNumber numberWithDouble:value];
    }
    return YES;
}

- (void)viewDidUnload {
    [self setIngredientsTableView:nil];
    [self setIngredientsSearchBar:nil];
    [super viewDidUnload];
}
@end
