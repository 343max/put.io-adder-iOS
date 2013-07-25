//
//  PAAddTorrentViewController.m
//  put.io adder
//
//  Created by Max Winde on 25.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <PutioKit/PKFolder.h>
#import "PKFolder+RootFolder.h"

#import "PAAddTorrentViewController.h"

#import "PAFolderChooserTableViewController.h"

@interface PAAddTorrentViewController ()

@property (strong) NSURL *torrentURL;

@property (strong) NSString *text;

@end

@implementation PAAddTorrentViewController

+ (UIViewController *)addTorrentViewController;
{
    PAAddTorrentViewController *viewController = [[PAAddTorrentViewController alloc] initWithStyle:UITableViewStyleGrouped];
    return [[UINavigationController alloc] initWithRootViewController:viewController];
}

- (void)setSelectedFolder:(PKFolder *)selectedFolder;
{
    if (selectedFolder == _selectedFolder) return;
    _selectedFolder = selectedFolder;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (id)initWithStyle:(UITableViewStyle)style;
{
    self = [super initWithStyle:style];
    
    if (self) {
        self.title = NSLocalizedString(@"Download Torrent", nil);
        self.selectedFolder = [PKFolder rootFolder];
    }
    
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (section == 0) {
        return NSLocalizedString(@"Torrent URL", nil);
    } else {
        return NSLocalizedString(@"Target Folder", nil);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (indexPath.section == 0) {
        if ([self.torrentURL isFileURL]) {
            cell.textLabel.text = self.torrentURL.lastPathComponent;
        } else {
            CGRect frame = cell.bounds;
            frame.origin.x += 15;
            frame.size.width -= 15 * 2;
            UITextField *textField = [[UITextField alloc] initWithFrame:frame];
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            textField.placeholder = NSLocalizedString(@"Torrent or Magnet URL", nil);
            textField.text = self.torrentURL.absoluteString;
            [cell addSubview:textField];
        }
    } else {
        cell.textLabel.text = self.selectedFolder.name;
        cell.imageView.image = [[UIImage imageNamed:@"Folder"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return indexPath.section == 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 1) {
        PAFolderChooserTableViewController *viewController = [[PAFolderChooserTableViewController alloc] initWithStyle:UITableViewStylePlain];
        viewController.addTorrentViewController = self;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
