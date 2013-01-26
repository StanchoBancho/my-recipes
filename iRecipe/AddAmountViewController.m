//
//  AddAmountViewController.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/24/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "AddAmountViewController.h"
#import "SQLiteReader.h"

@interface AddAmountViewController ()

@property(nonatomic, strong) SQLiteReader* dbReader;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UITextField *amountTextField;
@property (nonatomic, assign) float posibleMinValue;
@property (nonatomic, assign) float posibleMaxValue;

@end

@implementation AddAmountViewController

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
    
    self.title = @"Select Amount";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:doneButton];

    [self.amountTextField becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
    self.dbReader = [[SQLiteReader alloc] init];
    
    NSString *ingredientFkStatement = [NSString stringWithFormat:@"SELECT id FROM Ingredient WHERE name='%@'", self.selectedIngredient];
    NSInteger selectedIngredientFk = [[[[self.dbReader readDBWithQuery:ingredientFkStatement] lastObject] lastObject] integerValue];
    
    NSString* posibleMinValueStatement = [NSString stringWithFormat:@"SELECT MIN(realValue) FROM Relation WHERE IngredientFk=%d", selectedIngredientFk];
    self.posibleMinValue = [[[[self.dbReader readDBWithQuery:posibleMinValueStatement] lastObject] lastObject] floatValue];
    
    NSString* posibleMaxValueStatement = [NSString stringWithFormat:@"SELECT MAX(realValue) FROM Relation WHERE IngredientFk=%d", selectedIngredientFk];
    self.posibleMaxValue = [[[[self.dbReader readDBWithQuery:posibleMaxValueStatement] lastObject] lastObject] floatValue];
    
    self.infoLabel.text = [NSString stringWithFormat:@"Enter amount for the selected ingredient from %.2f to %.2f:", self.posibleMinValue, self.posibleMaxValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAmountTextField:nil];
    [self setInfoLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Action methods

- (IBAction)doneButtonPressed:(id)sender {
    float amount  = self.amountTextField.text.floatValue;
    if (amount < self.posibleMinValue || amount > self.posibleMaxValue) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat:@"Please enter an amount between %.2f and %.2f", self.posibleMinValue, self.posibleMaxValue] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(dissmissWithIngredient:)]){
        Ingredient* i = [[Ingredient alloc] init];
        [i setName:self.selectedIngredient];
        [i setRealValue:self.amountTextField.text.doubleValue];
        
        //setup name
        SQLiteReader* dbReader = [[SQLiteReader alloc] init];
        NSString* selectIngredientId = [NSString stringWithFormat:@"SELECT id FROM Ingredient WHERE name = '%@'", i.name];
        NSMutableArray* resultFromSelect = [dbReader readDBWithQuery:selectIngredientId];
        [i setPid:[[resultFromSelect objectAtIndex:0] objectAtIndex:0]];
        [self.delegate dissmissWithIngredient:i];
        
        //setup maxRealValue
        NSString* posibleMaxValueStatement = [NSString stringWithFormat:@"SELECT MAX(realValue) FROM Relation WHERE IngredientFk=%@", i.pid];
        NSMutableArray* resultFromMaxValueSelect = [dbReader readDBWithQuery:posibleMaxValueStatement];
        NSString* maxRealValueString = [NSString stringWithFormat:@"%.2f", [[[resultFromMaxValueSelect objectAtIndex:0] objectAtIndex:0] doubleValue]];
        double maxRealValue = [maxRealValueString doubleValue];
        [i setMaxRealValue:maxRealValue];
    }
}

@end
