//
//  PAFolderContentViewController.m
//  put.io adder
//
//  Created by Max Winde on 25.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PAPutIOController.h"

#import "PAFolderChooserViewController.h"

@interface PAFolderChooserViewController ()

@property (strong, nonatomic) NSArray *folders;

- (PKFolder *)folderForIndexPath:(NSIndexPath *)indexPath;

@end

@implementation PAFolderChooserViewController

+ (UIViewController *)chooserViewController;
{
    PAFolderChooserViewController *viewController = [[PAFolderChooserViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    return navigationController;
}

- (void)viewDidLoad;
{
    PKFolder *folder = [[PKFolder alloc] init];
    folder.id = @"-1";
    
    [[PAPutIOController sharedController].putIOClient getFolderItems:folder
                                                                    :^(NSArray *filesAndFolders)
     {
         NSArray *folders = [filesAndFolders select:^BOOL(id obj) {
             return [obj isKindOfClass:[PKFolder class]];
         }];
         
         self.folders = folders;
     }
                                                             failure:^(NSError *error)
     {
#warning handle the error!
         NSLog(@"error: %@", error);
     }];
}

- (void)setFolders:(NSArray *)folders;
{
    if (_folders == folders) return;
    
    _folders = folders;
    
    [self.tableView reloadData];
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
    }
    
    cell.textLabel.text = [self folderForIndexPath:indexPath].name;
    
    return cell;
}

@end
