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

@property (strong, nonatomic) IBOutlet UITextField *amountTextField;

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
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:doneButton];

    [self.amountTextField becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAmountTextField:nil];
    [super viewDidUnload];
}

#pragma mark - Action methods

- (IBAction)doneButtonPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(dissmissWithIngredient:)]){
        Ingredient* i = [[Ingredient alloc] init];
        [i setName:self.selectedIngredient];
        [i setRealValue:self.amountTextField.text.doubleValue];
        SQLiteReader* dbReader = [[SQLiteReader alloc] init];
        NSString* selectIngredientId = [NSString stringWithFormat:@"SELECT id FROM Ingredient WHERE name = '%@'", i.name];
        NSMutableArray* resultFromSelect = [dbReader readDBWithQuery:selectIngredientId];
        [i setPid:[[resultFromSelect objectAtIndex:0] objectAtIndex:0]];
        [self.delegate dissmissWithIngredient:i];
    }
}

@end
