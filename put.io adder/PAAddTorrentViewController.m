//
//  PAAddTorrentViewController.m
//  put.io adder
//
//  Created by Max Winde on 25.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <PutioKit/PKFolder.h>
#import "PKFolder+RootFolder.h"

#import "PAPutIOController.h"

#import "PAAddTorrentViewController.h"

#import "PAFolderChooserTableViewController.h"

@interface PAAddTorrentViewController ()

@property (strong) NSURL *torrentURL;

@property (strong) NSString *torrentURLString;

@property (strong) UIBarButtonItem *addButton;

@end

@implementation PAAddTorrentViewController

+ (UIViewController *)addTorrentViewControllerWithTorrentURL:(NSURL *)torrentURL;
{
    PAAddTorrentViewController *viewController = [[PAAddTorrentViewController alloc] initWithTorrentURL:torrentURL];
    return [[UINavigationController alloc] initWithRootViewController:viewController];
}

- (void)setSelectedFolder:(PKFolder *)selectedFolder;
{
    if (selectedFolder == _selectedFolder) return;
    _selectedFolder = selectedFolder;
    [self.tableView reloadData];
    
    [[NSUserDefaults standardUserDefaults] setObject:selectedFolder.dictionary forKey:@"selectedFolder"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addTorrent:(id)sender;
{
    NSURL *torrentURL = self.torrentURL;
    
    if (torrentURL == nil) {
        torrentURL = [NSURL URLWithString:self.torrentURLString];
    }
    
    [[PAPutIOController sharedController] downloadTorrent:torrentURL toFolder:self.selectedFolder];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)isValidTorrentURLString:(NSString *)string;
{
    return [[PAPutIOController sharedController] isTorrentURL:[NSURL URLWithString:string]];
}

#pragma mark - Table view data source

- (id)initWithTorrentURL:(NSURL *)torrentURL;
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        self.title = NSLocalizedString(@"Download Torrent", nil);
        
        NSDictionary *selectedFolderDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedFolder"];
        PKFolder *folder = [PKFolder folderWithDictionary:selectedFolderDict];
        if (folder) {
            self.selectedFolder = folder;
        } else {
            self.selectedFolder = [PKFolder rootFolder];
        }
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                             handler:^(id sender)
                                                 {
                                                     [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                 }];
        
        self.addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil)
                                                          style:UIBarButtonItemStyleDone
                                                         target:self
                                                         action:@selector(addTorrent:)];
        self.navigationItem.rightBarButtonItem = self.addButton;
        
        if ([torrentURL isFileURL]) {
            self.torrentURL = torrentURL;
        } else if (torrentURL != nil) {
            self.torrentURLString = torrentURL.absoluteString;
        } else if ([self isValidTorrentURLString:[UIPasteboard generalPasteboard].string]) {
            self.torrentURLString = [UIPasteboard generalPasteboard].string;
        } else {
            self.addButton.enabled = NO;
        }
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
            cell.imageView.image = [[UIImage imageNamed:@"File"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        } else {
            CGRect frame = cell.bounds;
            frame.origin.x += 15;
            frame.size.width -= 15 * 2;
            UITextField *textField = [[UITextField alloc] initWithFrame:frame];
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            textField.placeholder = NSLocalizedString(@"Torrent or Magnet URL", nil);
            textField.text = self.torrentURLString;
            [textField addEventHandler:^(UITextField *textField) {
                self.torrentURLString = textField.text;
                self.addButton.enabled = [self isValidTorrentURLString:self.torrentURLString];
            } forControlEvents:UIControlEventEditingChanged];
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
