//
//  PASearchViewController.m
//  put.io adder
//
//  Created by Max Winde on 26.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <BlocksKit/BlocksKit+UIKit.h>
#import "PASearchViewController.h"

NSString * const PASearchViewControllerDefaultSearchTemplate = @"http://archive.org/search.php?query=%s";

@interface PASearchViewController ()

@property UITextField *textField;
@property (strong) NSString *searchString;
@property (strong, nonatomic) NSArray *history;

@property (strong, nonatomic) NSString *searchEngineTemplate;

- (void)searchForString:(NSString *)searchString;
- (void)addToHistory:(NSString *)searchString;
- (void)searchSettings:(id)sender;

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
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                             handler:^(id sender)
                                                 {
                                                     [self.navigationController dismissViewControllerAnimated:YES
                                                                                                   completion:nil];
                                                 }];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(searchSettings:)];
    }
    return self;
}

- (void)searchSettings:(id)sender;
{
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:NSLocalizedString(@"Search Website", nil)
                                                     message:NSLocalizedString(@"URL of the WebSite to search. %s will be replaced by your search query.", nil)];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *URLField = [alertView textFieldAtIndex:0];
    URLField.placeholder = PASearchViewControllerDefaultSearchTemplate;
    URLField.text = self.searchEngineTemplate;
    URLField.keyboardType = UIKeyboardTypeURL;
    
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    
    [alertView bk_addButtonWithTitle:NSLocalizedString(@"Save", nil)
                          handler:^{
                              if (URLField.text == nil) {
                                  self.searchEngineTemplate = nil;
                              } else {
                                  NSURL *URL = [NSURL URLWithString:[URLField.text stringByReplacingOccurrencesOfString:@"%s"
                                                                                                             withString:@"sss"]];
                                  if ([URL.scheme isEqualToString:@"http"] || [URL.scheme isEqualToString:@"https"]) {
                                      self.searchEngineTemplate = URLField.text;
                                  }
                              }
                          }];
    
    [alertView show];
}

- (void)searchForString:(NSString *)searchString
{
    NSString *template = (self.searchEngineTemplate ?: PASearchViewControllerDefaultSearchTemplate);
    NSRange placeholderRange = [template rangeOfString:@"%s"];
    NSURL *searchURL;
    if (placeholderRange.location == NSNotFound) {
        NSAssert(NO, @"no placeholder string %%s found in search template");
        searchURL = [NSURL URLWithString:template];
    } else {
        NSString *URLstring = [template stringByReplacingCharactersInRange:placeholderRange
                                                                withString:[searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        searchURL = [NSURL URLWithString:URLstring];
    }
    
    [[UIApplication sharedApplication] openURL:searchURL];
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:NO completion:nil];
    });
}


@synthesize history = _history;

- (NSArray *)history;
{
    if (_history == nil) {
        _history = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SearchHistory"] nilUnlessKindOfClass:[NSArray class]];
    }
    
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
    while (history.count > 20) {
        [history removeObject:[history lastObject]];
    }
    self.history = [history copy];
}

@synthesize searchEngineTemplate = _searchEngineTemplate;

- (void)setSearchEngineTemplate:(NSString *)searchEngineTemplate;
{
    if ([searchEngineTemplate isEqualToString:_searchEngineTemplate]) return;
    
    _searchEngineTemplate = searchEngineTemplate;
    
    [[NSUserDefaults standardUserDefaults] setObject:searchEngineTemplate forKey:@"SearchEngineTemplate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)searchEngineTemplate;
{
    if (_searchEngineTemplate == nil) {
        _searchEngineTemplate = [[NSUserDefaults standardUserDefaults] stringForKey:@"SearchEngineTemplate"];
    };
    
    return _searchEngineTemplate;
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
            
            [textField bk_addEventHandler:^(UITextField *textField) {
                self.searchString = textField.text;
            } forControlEvents:UIControlEventValueChanged];
            
            self.textField = textField;
            
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
        self.textField.text = self.history[indexPath.row];
        [self.textField becomeFirstResponder];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (section == 1) {
        return NSLocalizedString(@"Search History", nil);
    }
    
    return nil;
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
