//
//  PAFilesViewController.m
//  put.io adder
//
//  Created by Thomas Kollbach on 08.09.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <BlocksKit/BlocksKit.h>

#import "PAPutIOController.h"

#import "PAFileViewController.h"
#import "PAFilesViewController.h"


@interface PAFilesViewController () <UISearchDisplayDelegate>

@property (nonatomic) NSArray *filesAndFolders;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UISearchDisplayController *searchController;
@property (nonatomic) NSArray *filteredFilesAndFolders;

@property (nonatomic) PKFolder *folder;

@end

@implementation PAFilesViewController

- (id)initWithFolder:(PKFolder *)folder;
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _filteredFilesAndFolders = @[];
        _folder = folder;
        if (!_folder) {
            self.title = NSLocalizedString(@"Files", nil);
        } else {
            self.title = _folder.displayName;
        }
    }
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PAPutIOControllerFilesAndFoldersDidReloadNotification
                                                  object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFilesAndFolders)
                                                 name:PAPutIOControllerFilesAndFoldersDidReloadNotification
                                               object:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(reloadFiles:)
                  forControlEvents:UIControlEventValueChanged];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    self.tableView.tableHeaderView = self.searchBar;
    
    [self updateFilesAndFolders];
}

- (UISearchDisplayController *)searchDisplayController;
{
    return self.searchController;
}

- (void)didMoveToParentViewController:(UIViewController *)parent;
{
    [super didMoveToParentViewController:parent];
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:parent];
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;
    
}


#pragma mark Actions

- (IBAction)reloadFiles:(id)sender;
{
    [[PAPutIOController sharedController] reloadFilesAndFolders:^(NSError *error) {
        [self.refreshControl endRefreshing];
        
        if (error) {
            [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"Error", nil)
                                        message:error.localizedDescription
                              cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                              otherButtonTitles:@[ NSLocalizedString(@"Retry", nil) ]
                                        handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                            if (buttonIndex != alertView.cancelButtonIndex) {
                                                [self performSelector:@selector(reloadFiles:) withObject:alertView afterDelay:0.0];
                                            }
                                        }];
            
        } else {
            [self updateFilesAndFolders];
        }
    }];
}


#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (tableView == self.tableView) {
        return self.filesAndFolders.count;
    } else if (tableView == self.searchController.searchResultsTableView) {
        return self.filteredFilesAndFolders.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    id item = [self itemForIndexPath:indexPath inTableView:tableView];
    if ([item isKindOfClass:[PKFolder class]]) {
        PKFolder *folder = item;
        cell.textLabel.text = folder.displayName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [[UIImage imageNamed:@"Folder"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
    } else if ([item isKindOfClass:[PKFile class]]) {
        PKFile *file = item;
        cell.textLabel.text = file.displayName;
        cell.detailTextLabel.text = file.contentType;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.imageView.image = nil;
    }
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *controller;
    id item = [self itemForIndexPath:indexPath inTableView:tableView];
    if ([item isKindOfClass:[PKFolder class]]) {
        PKFolder *folder = item;
        controller = [[PAFilesViewController alloc] initWithFolder:folder];
    } else if ([item isKindOfClass:[PKFile class]]) {
        PKFile *file = item;
        controller = [[PAFileViewController alloc] initWithFile:file];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString;
{
    self.filteredFilesAndFolders = [self.filesAndFolders select:^BOOL(PKFile *obj) {
        return [obj.displayName rangeOfString:searchString options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location != NSNotFound;
    }];
    return YES;
}

#pragma mark Helpers

- (id)itemForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
{
    if (tableView == self.tableView) {
        return self.filesAndFolders[indexPath.row];
    } else if (tableView == self.searchController.searchResultsTableView) {
        return self.filteredFilesAndFolders[indexPath.row];
    }

    return nil;
}

- (void)updateFilesAndFolders;
{
    NSMutableArray *filesAndFolders = [NSMutableArray array];
    
    NSString *folderID = self.folder.id;
    if (!folderID) folderID = @"0";
    
    for (PKFile *file in [[PAPutIOController sharedController] files]) {
        if ([file.parentID isEqual:folderID]) {
            [filesAndFolders addObject:file];
        }
    }
    
    for (PKFolder *folder in [[PAPutIOController sharedController] folders]) {
        if ([folder.parentID isEqual:folderID]) {
            [filesAndFolders addObject:folder];
        }
    }

    self.filesAndFolders = [filesAndFolders sortedArrayUsingComparator:^NSComparisonResult(PKFolder *obj1, PKFolder *obj2) {
        return [obj1.name caseInsensitiveCompare:obj2.name];
    }];
    
    [self.tableView reloadData];
}


@end
