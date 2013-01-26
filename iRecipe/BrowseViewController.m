//
//  BrowseViewController.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/21/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "BrowseViewController.h"
#import "SQLiteReader.h"
#import "ShowRecipesViewController.h"
#import "Recipe.h"
#import "Ingredient.h"
#import "UIView+Additions.h"

@interface BrowseViewController ()
{
    BOOL isAlreadyLoadTheCategories;
}
@property(nonatomic, strong) NSMutableArray* categories;
@property (strong, nonatomic) IBOutlet UITableView *categoryTableView;

@property (strong, nonatomic) SQLiteReader* dbReader;
@end

static NSString* categoryCellIdentifier = @"categoryCellIdentifier";

@implementation BrowseViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self setView:[[[NSBundle mainBundle] loadNibNamed:@"BrowseViewController" owner:self options:nil] objectAtIndex:0]];
        self.categories = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.categoryTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:categoryCellIdentifier];
    [self.navigationItem setTitle:@"Categories"];
    isAlreadyLoadTheCategories = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!isAlreadyLoadTheCategories){
        self.dbReader = [[SQLiteReader alloc] init];
        NSString* selectStatement = @"SELECT DISTINCT category FROM Recipe";
        NSMutableArray* rowData = [self.dbReader readDBWithQuery:selectStatement];
        for(NSMutableArray* recipe in rowData){
            NSString* categoryName = [recipe objectAtIndex:0];
            [self.categories addObject:categoryName];
        }
        isAlreadyLoadTheCategories= YES;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categories count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView dequeueReusableCellWithIdentifier:categoryCellIdentifier forIndexPath:indexPath];
    UITableViewCell* categoryCell = [tableView dequeueReusableCellWithIdentifier:categoryCellIdentifier];
    [categoryCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [[categoryCell textLabel] setText:[self.categories objectAtIndex:indexPath.row]];
    return categoryCell;
}

#pragma mark - UITableView Delegate

-(void)populateIngredientsOfRecipe:(Recipe*)recipe
{
    //get ingredients info
    NSString* selectStatement = [NSString stringWithFormat:@"SELECT * FROM Relation WHERE recipeFk = %@",recipe.pid];
    NSMutableArray* ingredientsRelations = [self.dbReader readDBWithQuery:selectStatement];
    
    NSMutableArray* ingredients = [[NSMutableArray alloc] init];
    for(NSMutableArray* iRelation in ingredientsRelations){
        //setup each ingredient
        Ingredient* i = [[Ingredient alloc] init];
        
        //setup pid, quantity, measure & realValue
        NSString* ingredientFk = [iRelation objectAtIndex:1];
        [i setPid:ingredientFk];
        
        NSString* quantityString = [iRelation objectAtIndex:3];
        double quantity = [quantityString doubleValue];
        NSNumber* quantityNumber = [NSNumber numberWithDouble:quantity];
        [i setQuantity:quantityNumber];
        
        NSString* measure = [iRelation objectAtIndex:4];
        [i setMeasure:measure];
        
        NSString* realValueString = [NSString stringWithFormat:@"%.2f", [[iRelation objectAtIndex:5] doubleValue]];
        double realValue = [realValueString doubleValue];
        [i setRealValue:realValue];
        
        //get the name of ingredient
        NSString* selectIngredientName = [NSString stringWithFormat:@"SELECT name FROM Ingredient WHERE id = %@",i.pid];
        NSMutableArray* ingredientNameResult = [self.dbReader readDBWithQuery:selectIngredientName];
        NSString* ingredientName = [[ingredientNameResult objectAtIndex:0] objectAtIndex:0];
        [i setName:ingredientName];
        
        [ingredients addObject:i];
    }
    [recipe setIngredients:ingredients];
}

-(Recipe*)populateRecipeWithId:(NSString*)recipeId
{
    Recipe* newRecipe = [[Recipe alloc] init];
    [newRecipe setUsed:NO];
    [newRecipe setPid:recipeId];
    NSString* selectStatement = [NSString stringWithFormat:@"SELECT * FROM Recipe WHERE id = %@",recipeId];
    NSMutableArray* recipeResult = [self.dbReader readDBWithQuery:selectStatement];
    
    NSString* name = [[recipeResult objectAtIndex:0] objectAtIndex:1];
    [newRecipe setName:name];
    
    NSString* howTo = [[recipeResult objectAtIndex:0] objectAtIndex:2];
    [newRecipe setHowTo:howTo];
    
    double preparationTime = [(NSString*)[[recipeResult objectAtIndex:0] objectAtIndex:3] doubleValue];
    NSNumber* preparationTimeNumber = [NSNumber numberWithDouble:preparationTime];
    [newRecipe setPreparationTime:preparationTimeNumber];
    
    [self populateIngredientsOfRecipe:newRecipe];
    
    return newRecipe;
}

-(NSMutableArray*)getRecipesForCategory:(NSString*)categoryName
{
    //select desired recipe ids
    NSMutableString* selectRecipeIdsStatement =[NSMutableString stringWithFormat:@"SELECT DISTINCT id FROM Recipe WHERE category = '%@'", categoryName];
    
    NSMutableArray* recipeIds = [self.dbReader readDBWithQuery:selectRecipeIdsStatement];
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    for(NSMutableArray* id in recipeIds){
        NSString* recipeId = [id objectAtIndex:0];
        Recipe* recipe = [self populateRecipeWithId:recipeId];
        [result addObject:recipe];
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.categoryTableView setUserInteractionEnabled:NO];
    
    UIView* loadingView = [UIView presentPositiveNotifyingViewWithTitle:@"Loading..."onView:self.view];
    [self.view addSubview:loadingView];
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(backgroundQueue, ^{
        NSString* selectedCategory = [self.categories objectAtIndex:indexPath.row];
        NSMutableArray* recipesFromThisCategory = [self getRecipesForCategory:selectedCategory];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ShowRecipesViewController *recipesVC = [[ShowRecipesViewController alloc] initWithNibName:@"ShowRecipesViewController" bundle:nil];
            recipesVC.datasource = recipesFromThisCategory;
            recipesVC.titleOfTheNavigationBar = selectedCategory;
            [loadingView removeFromSuperview];
            [self.categoryTableView setUserInteractionEnabled:YES];
            [self.navigationController pushViewController:recipesVC animated:YES];
        });
    });
}


- (void)viewDidUnload {
    [self setCategoryTableView:nil];
    [super viewDidUnload];
}
@end
