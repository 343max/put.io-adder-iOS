//
//  PASearchViewController.m
//  put.io adder
//
//  Created by Max Winde on 26.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PASearchViewController.h"

@interface PASearchViewController ()

@property (strong) NSString *searchText;

@end

@implementation PASearchViewController

+ (UIViewController *)searchViewController;
{
    PASearchViewController *searchViewController = [[PASearchViewController alloc] initWithStyle:UITableViewStyleGrouped];
    return [[UINavigationController alloc] initWithRootViewController:searchViewController];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                             handler:^(id sender)
                                                 {
                                                     [self.navigationController dismissViewControllerAnimated:YES
                                                                                                   completion:nil];
                                                 }];
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString * const SearchCellIdentifier = @"SearchCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier];
            CGRect frame = cell.bounds;
            frame.origin.x = 15.0;
            frame.size.width -= 15.0 * 2;
            UITextField *textField = [[UITextField alloc] initWithFrame:frame];
            textField.text = self.searchText;
            textField.returnKeyType = UIReturnKeySearch;
            textField.placeholder = NSLocalizedString(@"Search", nil);
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            [textField addEventHandler:^(UITextField *textField) {
                self.searchText = textField.text;
            } forControlEvents:UIControlEventValueChanged];
            
            [cell addSubview:textField];
        }
        
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return indexPath.section != 0;
}

@end
