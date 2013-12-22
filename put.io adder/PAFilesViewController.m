//
//  PAFilesViewController.m
//  put.io adder
//
//  Created by Thomas Kollbach on 08.09.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <BlocksKit/BlocksKit.h>
#import <FormatterKit/TTTUnitOfInformationFormatter.h>

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


#pragma mark UIViewController

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
    self.searchBar.placeholder = NSLocalizedString(@"Search", nil);
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
    cell.detailTextLabel.text = nil;
    
    id item = [self itemForIndexPath:indexPath inTableView:tableView];
    if ([item isKindOfClass:[PKFolder class]]) {
        PKFolder *folder = item;
        cell.textLabel.text = folder.displayName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [self imageForIndexPath:indexPath inTableView:tableView];
        
    } else if ([item isKindOfClass:[PKFile class]]) {
        PKFile *file = item;
        cell.textLabel.text = file.displayName;
        if (file.size.unsignedIntegerValue > 0) {
            TTTUnitOfInformationFormatter *formatter = [[TTTUnitOfInformationFormatter alloc] init];
            formatter.numberFormatter.locale = [NSLocale currentLocale];
            formatter.numberFormatter.roundingIncrement = @.001;
            formatter.numberFormatter.minimumFractionDigits = 0;
            formatter.numberFormatter.maximumFractionDigits = 2;
            
            
            cell.detailTextLabel.text = [formatter stringFromNumber:file.size ofUnit:TTTByte];
//            NSLog(@"%@ byts %@ KB %.2f MB %.2f", file.name, file.size, file.size.doubleValue / 1024.0, file.size.doubleValue / 1024.0 / 1024.0);
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.imageView.image = [self imageForIndexPath:indexPath inTableView:tableView];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!editingStyle == UITableViewCellEditingStyleDelete) {
        return;
    }
    id<PKFolderItem> item = [self itemForIndexPath:indexPath inTableView:tableView];
    
    [[PAPutIOController sharedController] deleteItem:item callback:^(NSError *error) {
        if (!error) {
            NSMutableArray *mutableFilesAndFolders = [self.filesAndFolders mutableCopy];
            NSInteger index = [mutableFilesAndFolders indexOfObject:item];
            
            if (index != NSNotFound) {
                [mutableFilesAndFolders removeObjectAtIndex:index];
                
                [tableView beginUpdates];
                self.filesAndFolders = [mutableFilesAndFolders copy];
                [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationTop];
                [tableView endUpdates];
            }
            
        } else if ([error.domain isEqualToString:AFNetworkingErrorDomain]) {
            NSInteger statusCode = [error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
            if (statusCode == 404) {
                NSMutableArray *mutableFilesAndFolders = [self.filesAndFolders mutableCopy];
                NSInteger index = [mutableFilesAndFolders indexOfObject:item];
                
                if (index != NSNotFound) {
                    [mutableFilesAndFolders removeObjectAtIndex:index];
                    
                    [tableView beginUpdates];
                    self.filesAndFolders = [mutableFilesAndFolders copy];
                    [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationTop];
                    [tableView endUpdates];
                }
            }
        } else {
            
            [tableView setEditing:NO animated:YES];
            
            [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"Error", nil)
                                        message:error.localizedDescription
                              cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                              otherButtonTitles:@[]
                                        handler:NULL];
        }
    }];
}

- (NSString *)formattedFileSizeStringFromBytes:(NSNumber *)number;
{
//    unsigned long long bytes = number.unsignedLongLongValue;
//    if (bytes < 1024) {
//        <#statements#>
//    }
    return number.stringValue;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setEditing:YES animated:YES];
}

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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
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

- (UIImage *)imageForIndexPath:(NSIndexPath *)path inTableView:(UITableView *)tableView;
{
    UIImage *image = [UIImage imageNamed:@"File"];
    id item = [self itemForIndexPath:path inTableView:tableView];
    if ([item isKindOfClass:[PKFolder class]]) {
        image = [UIImage imageNamed:@"Folder"];
    } else if ([item isKindOfClass:[PKFile class]]) {
        PKFile *file = item;
        
        if ([file.contentType hasPrefix:@"video/"]) {
            image = [UIImage imageNamed:@"Video"];
        } else if ([file.contentType hasPrefix:@"image/"]) {
            image = [UIImage imageNamed:@"Picture"];
        } else if ([file.contentType hasPrefix:@"text/"]) {
            image = [UIImage imageNamed:@"Text"];
        } else if ([file.contentType hasPrefix:@"audio/"]) {
            image = [UIImage imageNamed:@"Sound"];
        }
    }
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];;
}

@end
