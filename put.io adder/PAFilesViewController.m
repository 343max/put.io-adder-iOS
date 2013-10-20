//
//  PAFilesViewController.m
//  put.io adder
//
//  Created by Thomas Kollbach on 08.09.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PAPutIOController.h"

#import "PAFileViewController.h"
#import "PAFilesViewController.h"


@interface PAFilesViewController ()

@property (nonatomic) NSArray *filesAndFolders;

@property (nonatomic) PKFolder *folder;

@end

@implementation PAFilesViewController

- (id)initWithFolder:(PKFolder *)folder;
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _folder = folder;
        if (!_folder) {
            self.title = NSLocalizedString(@"Files", nil);
        } else {
            self.title = _folder.displayName;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(reloadFiles)
                  forControlEvents:UIControlEventValueChanged];
    
    [self updateFilesAndFolders];
}


#pragma mark Actions

- (IBAction)reloadFiles;
{
    [[PAPutIOController sharedController] reloadFilesAndFolders:^(NSError *error) {
        [self.refreshControl endRefreshing];
        
        [self updateFilesAndFolders];
        
#warning Error handling
        NSLog(@"eror %@", error);
    }];
}


#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.filesAndFolders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    id item = self.filesAndFolders[indexPath.row];
    if ([item isKindOfClass:[PKFolder class]]) {
        PKFolder *folder = item;
        cell.textLabel.text = folder.displayName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [[UIImage imageNamed:@"Folder"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
    } else if ([item isKindOfClass:[PKFile class]]) {
        PKFile *file = item;
        cell.textLabel.text = file.displayName;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *controller;
    id item = self.filesAndFolders[indexPath.row];
    if ([item isKindOfClass:[PKFolder class]]) {
        PKFolder *folder = item;
        controller = [[PAFilesViewController alloc] initWithFolder:folder];
    } else if ([item isKindOfClass:[PKFile class]]) {
        PKFile *file = item;
        controller = [[PAFileViewController alloc] initWithFile:file];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark Helpers

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
