//
//  PASearchViewController.m
//  put.io adder
//
//  Created by Max Winde on 26.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PASearchViewController.h"

@interface PASearchViewController ()

@property (strong) NSString *searchString;
@property (strong, nonatomic) NSArray *history;

- (void)searchForString:(NSString *)searchString;
- (void)addToHistory:(NSString *)searchString;

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

- (void)searchForString:(NSString *)searchString
{
    NSLog(@"search: %@", searchString);
}


@synthesize history = _history;

- (NSArray *)history;
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _history = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SearchHistory"] nilUnlessKindOfClass:[NSArray class]];
    });
    
    return _history;
}

- (void)setHistory:(NSArray *)history;
{
    if ([history isEqualToArray:_history]) return;
    
    _history = history;
    
    [[NSUserDefaults standardUserDefaults] setObject:history forKey:@"SearchHistory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addToHistory:(NSString *)searchString;
{
    NSMutableArray *history = ([self.history mutableCopy] ?: [[NSMutableArray alloc] init]);
    [history removeObject:searchString];
    [history insertObject:searchString atIndex:0];
    self.history = [history copy];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return self.history.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString * const SearchCellIdentifier = @"SearchCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier];
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
            textField.frame = ({
                CGRect frame = cell.bounds;
                frame.origin.x += 15.0;
                frame.size.width -= 15.0 * 2;
                frame;
            });
            textField.text = self.searchString;
            textField.returnKeyType = UIReturnKeySearch;
            textField.placeholder = NSLocalizedString(@"Search", nil);
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            textField.delegate = self;
            
            [textField addEventHandler:^(UITextField *textField) {
                self.searchString = textField.text;
            } forControlEvents:UIControlEventValueChanged];
            
            
            [cell addSubview:textField];
        }
        
        return cell;
    } else {
        NSString * const HistoryCellIdentifier = @"HistoryCellIdentifier";
        UITableViewCell *cell = ([tableView dequeueReusableCellWithIdentifier:HistoryCellIdentifier] ?:
                                 [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                        reuseIdentifier:HistoryCellIdentifier]);
        
        cell.textLabel.text = self.history[indexPath.row];
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return indexPath.section != 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 1) {
        [self searchForString:self.history[indexPath.row]];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    self.searchString = textField.text;
    [self addToHistory:self.searchString];
    [self.tableView reloadData];
    [self searchForString:self.searchString];
    [textField resignFirstResponder];
    return YES;
}


@end
