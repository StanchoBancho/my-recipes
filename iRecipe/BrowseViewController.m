//
//  BrowseViewController.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 1/21/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "BrowseViewController.h"
#import "SQLiteReader.h"

@interface BrowseViewController ()

@property(nonatomic, strong) NSMutableArray* categories;
@property (strong, nonatomic) IBOutlet UITableView *categoryTableView;

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
}

-(void)viewWillAppear:(BOOL)animated
{
    SQLiteReader* reader = [[SQLiteReader alloc] init];
    NSString* selectStatement = @"SELECT DISTINCT category FROM Recipe";
    NSMutableArray* rowData = [reader readDBWithQuery:selectStatement];
    for(NSMutableArray* recipe in rowData){
        NSString* categoryName = [recipe objectAtIndex:0];
        [self.categories addObject:categoryName];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


- (void)viewDidUnload {
    [self setCategoryTableView:nil];
    [super viewDidUnload];
}
@end
