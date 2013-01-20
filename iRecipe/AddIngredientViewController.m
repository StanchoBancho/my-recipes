//
//  AddIngredientViewController.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/18/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "AddIngredientViewController.h"

@interface AddIngredientViewController ()<UITextFieldDelegate>

@property(nonatomic, strong) IBOutlet UITextField* ingredientTextField;
@property(nonatomic, strong) IBOutlet UITextField* quantityTextField;

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
    // Do any additional setup after loading the view from its nib.
}

-(void)awakeFromNib
{
    NSLog(@"%d", self.ingredientTextField.editing);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonPressed:(id)sender
{
    [[self ingredientTextField] resignFirstResponder];
    [[self quantityTextField] resignFirstResponder];
    if(self.delegate && [self.delegate respondsToSelector:@selector(dissmissWithIngredientName:andQuantity:)]){
        [self.delegate dissmissWithIngredientName:self.name andQuantity:self.quantity];
    }
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

@end
