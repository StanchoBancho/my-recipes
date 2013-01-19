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
@property(nonatomic, copy) NSNumber* quantity;

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
    [self.ingredientTextField setEnabled:YES];
    NSLog(@"%d", self.ingredientTextField.editing);
    // Do any additional setup after loading the view from its nib.
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
    if(self.delegate && [self.delegate respondsToSelector:@selector(dissmissWithIngredientName:andQuantity:)]){
        [self.delegate dissmissWithIngredientName:self.name andQuantity:self.quantity];
    }
}

//#pragma mark - UITableView DataSource
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 1;
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 2;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if(section == 0){
//        return @"Ingredient name";
//    }
//    else{
//        return @"Quantity";
//    }
//}
//   
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell* result = nil;
//    switch (indexPath.section) {
//        case 0:
//            result = self.ingredientTableViewCell;
//            break;
//        case 1:
//            result = self.quantiryTableViewCell;
//            break;
//        default:
//            break;
//    }
//    return result;
//}
//
//#pragma mark - UITableView Delegate
//
//- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return NO;
//}
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleNone;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return NO;
//}
//
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGFloat result = 0.0;
//    switch (indexPath.section) {
//        case 0:
//            result = self.ingredientTableViewCell.frame.size.height;
//            break;
//        case 1:
//            result = self.quantiryTableViewCell.frame.size.height;
//            break;
//        default:
//            break;
//    }
//    return result;
//}

#pragma mark - UITextField Delegate





//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    if(textField.tag == 1){
//        self.name = textField.text;
//    }
//    else if(textField.tag == 2){
//        double value = [textField.text doubleValue];
//        self.quantity =[NSNumber numberWithDouble:value];
//    }
//    return NO;
//}

@end
