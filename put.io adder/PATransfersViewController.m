//
//  PATransfersViewController.m
//  put.io adder
//
//  Created by Max Winde on 23.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PAPutIOController.h"
#import "PATransferCategory.h"

#import "PATransfersViewController.h"

@interface PATransfersViewController ()

@property (strong, nonatomic) NSArray *transfers;
@property (strong, nonatomic) NSArray *transferCategories;
@property (strong) NSTimer *refreshTimer;

- (void)reloadTransfers;
- (PKTransfer *)tranferForIndexPath:(NSIndexPath *)indexPath;
- (PATransferCategory *)categoryForSection:(NSInteger)section;

- (void)addTorrent:(id)sender;

@end

@implementation PATransfersViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"Transfers", @"Transfers View Controller Title");
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadTransfers)
                                                     name:PAPutIOControllerTransfersDidChangeNotification
                                                   object:nil];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                               target:self
                                                                                               action:@selector(addTorrent:)];
    }
    return self;
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(reloadTransfers)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
    [self reloadTransfers];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    
    [self.refreshTimer invalidate];
}

- (void)reloadTransfers;
{
    [self.refreshTimer invalidate];
    [self.refreshControl beginRefreshing];
    
    V2PutIOAPIClient *client = [PAPutIOController sharedController].putIOClient;
    
    if (client.ready == NO) return;
    
    [client getTransfers:^(NSArray *transfers) {
        self.transfers = transfers;
        
        [self.refreshControl endRefreshing];
        
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                             target:self
                                                           selector:@selector(reloadTransfers)
                                                           userInfo:nil
                                                            repeats:NO];
    } failure:^(NSError *error) {
        [self.refreshControl endRefreshing];
        
        NSLog(@"error: %@", error);
        
        [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"Error", @"Error Alert View Title")
                                    message:error.localizedDescription
                          cancelButtonTitle:NSLocalizedString(@"Okay", @"Okay button title")
                          otherButtonTitles:nil
                                    handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                        //
                                    }];
    }];
}

- (void)setTransfers:(NSArray *)transfers;
{
    if (transfers == _transfers) return;
    
    _transfers = transfers;
    
    NSMutableDictionary *transfersDict = [[NSMutableDictionary alloc] init];
    
    [transfers each:^(PKTransfer *transfer) {
        NSNumber *status = @(transfer.transferStatus);
        
        if (transfersDict[status] == nil) {
            transfersDict[status] = [[NSMutableArray alloc] init];
        }
        
        [transfersDict[status] addObject:transfer];
    }];
    
    NSArray *order = @[@(PKTransferStatusUnknown), @(PKTransferStatusError), @(PKTransferStatusDownloading), @(PKTransferStatusSeeding), @(PKTransferStatusCompleted)];
    
    NSDictionary *titles = @{@(PKTransferStatusUnknown): NSLocalizedString(@"Unknown", nil),
                             @(PKTransferStatusError): NSLocalizedString(@"Error", nil),
                             @(PKTransferStatusDownloading): NSLocalizedString(@"Downloading", nil),
                             @(PKTransferStatusSeeding): NSLocalizedString(@"Seeding", nil),
                             @(PKTransferStatusCompleted): NSLocalizedString(@"Completed", nil)};
    
    NSMutableArray *categories = [[NSMutableArray alloc] initWithCapacity:transfersDict.count];
    
    [order each:^(NSNumber *status) {
        PATransferCategory *category = [[PATransferCategory alloc] initWithTitle:titles[status]
                                                                       transfers:transfersDict[status]];
        
        if (category.transfers.count != 0) {
            [categories addObject:category];
        }
    }];
    
    self.transferCategories = categories;
}

- (void)setTransferCategories:(NSArray *)transferCategories;
{
    if (transferCategories == _transferCategories) return;
    
    _transferCategories = transferCategories;
    
    [self.tableView reloadData];
}

- (PATransferCategory *)categoryForSection:(NSInteger)section;
{
    return self.transferCategories[section];
}

- (PKTransfer *)tranferForIndexPath:(NSIndexPath *)indexPath;
{
    return [self categoryForSection:indexPath.section].transfers[indexPath.row];
}

- (void)addTorrent:(id)sender;
{
    UIAlertView *alertView = [UIAlertView alertViewWithTitle:NSLocalizedString(@"Add torrent or magnet URL:", nil)];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    __weak UITextField *URLTextField = [alertView textFieldAtIndex:0];
    URLTextField.placeholder = NSLocalizedString(@"http://link.to.the/torrent.URL", nil);
    URLTextField.keyboardType = UIKeyboardTypeURL;
    
    NSURL *pasteboradURL = [NSURL URLWithString:[UIPasteboard generalPasteboard].string];
    if ([[PAPutIOController sharedController] isTorrentURL:pasteboradURL]) {
        URLTextField.text = pasteboradURL.absoluteString;
    }
    
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                          handler:nil];
    
    [alertView addButtonWithTitle:NSLocalizedString(@"Add", nil)
                          handler:^{
                              NSURL *URL = [NSURL URLWithString:URLTextField.text];
                              
                              if ([[PAPutIOController sharedController] isTorrentURL:URL]) {
                                  [[PAPutIOController sharedController] addTorrent:URL];
                              }
                          }];
    
    alertView.cancelButtonIndex = 0;
    
    [alertView show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.transferCategories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self categoryForSection:section].transfers.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    return [self categoryForSection:section].title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    PKTransfer *transfer = [self tranferForIndexPath:indexPath];
    cell.textLabel.text = transfer.name;
    cell.detailTextLabel.text = transfer.statusMessage;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return NO;
}


@end
