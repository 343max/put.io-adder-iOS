//
//  PAFolderContentViewController.m
//  put.io adder
//
//  Created by Max Winde on 25.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PKFolder+RootFolder.h"
#import "PAPutIOController.h"
#import "PAAddTorrentViewController.h"

#import "PAFolderChooserTableViewController.h"

@interface PAFolderChooserTableViewController ()

@property (strong, nonatomic) NSArray *folders;

- (PKFolder *)folderForIndexPath:(NSIndexPath *)indexPath;

@end

@implementation PAFolderChooserTableViewController

- (id)initWithStyle:(UITableViewStyle)style;
{
    self = [super initWithStyle:style];
    
    if (self) {
        self.title = NSLocalizedString(@"Choose Folder", nil);
    }
    
    return self;
}

- (void)viewDidLoad;
{
    
    [[PAPutIOController sharedController] reloadFilesAndFolders:^(NSError *error) {
        if (error) {
#warning handle the error!
            NSLog(@"error: %@", error);
        } else {
            
            self.folders = [[PAPutIOController sharedController] folders];
        }
    }];
}

- (NSArray *)flatFoldersFromFolderDict:(NSDictionary *)foldersByParent
                         forRootFolder:(NSString *)rootFolderIdentifer
                               atDepth:(NSInteger)depth;
{
    NSArray *folders = foldersByParent[rootFolderIdentifer];
    
    NSMutableArray *flatFolders = [[NSMutableArray alloc] initWithCapacity:folders.count];
    
    if ([rootFolderIdentifer isEqualToString:[PKFolder rootFolder].id]) {
        [flatFolders addObject:[PKFolder rootFolder]];
    }
    
    [folders each:^(PKFolder *folder) {
        folder.numberOfParentFolders = depth;
        [flatFolders addObject:folder];
        [flatFolders addObjectsFromArray:[self flatFoldersFromFolderDict:foldersByParent
                                                           forRootFolder:folder.id
                                                                 atDepth:depth + 1]];
    }];
    
    return [flatFolders copy];
}

- (void)setFolders:(NSArray *)folders;
{
    if (_folders == folders) return;
    
    NSMutableDictionary *foldersByParent = [[NSMutableDictionary alloc] init];
    [folders each:^(PKFolder *folder) {
        if (foldersByParent[folder.parentID] == nil) {
            foldersByParent[folder.parentID] = [[NSMutableArray alloc] init];
        }
        [foldersByParent[folder.parentID] addObject:folder];
    }];
    
    [foldersByParent each:^(NSString *parentId, NSMutableArray *arrayOfFolders) {
        [arrayOfFolders sortUsingComparator:^NSComparisonResult(PKFolder *folder1, PKFolder *folder2) {
            return [folder1.name compare:folder2.name];
        }];
    }];
    
    _folders = [self flatFoldersFromFolderDict:foldersByParent forRootFolder:[PKFolder rootFolder].id atDepth:0];
    
    [self.tableView reloadData];

    [_folders each:^(PKFolder *folder) {
        if ([folder.id isEqualToString:self.addTorrentViewController.selectedFolder.id]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_folders indexOfObject:folder] inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
    }];
}

- (PKFolder *)folderForIndexPath:(NSIndexPath *)indexPath;
{
    return self.folders[indexPath.row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.folders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.imageView.image = [[UIImage imageNamed:@"Folder"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.indentationWidth = 10.0;
    }
    
    PKFolder *folder = [self folderForIndexPath:indexPath];
    
    cell.textLabel.text = folder.name;
    cell.indentationLevel = folder.numberOfParentFolders + 1;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    self.addTorrentViewController.selectedFolder = [self folderForIndexPath:indexPath];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
