//
//  PATransfersViewController.m
//  put.io adder
//
//  Created by Max Winde on 23.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PAPutIOController.h"
#import "PAAddTorrentViewController.h"
#import "PASearchViewController.h"
#import "PATransferCategory.h"
#import "PATransferCell.h"

#import "PATransfersViewController.h"

@interface PATransfersViewController ()

@property (strong, nonatomic) NSArray *transfers;
@property (strong, nonatomic) NSArray *transferCategories;
@property (strong) NSTimer *refreshTimer;

- (void)reloadTransfers;
- (PKTransfer *)tranferForIndexPath:(NSIndexPath *)indexPath;
- (PATransferCategory *)categoryForSection:(NSInteger)section;

- (BOOL)isClearCompletedCell:(NSIndexPath *)indexPath;

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
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                              target:self
                                                                                              action:@selector(startSearch:)];
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
    
    NSArray *order = @[@(PKTransferStatusUnknown),
                       @(PKTransferStatusError),
                       @(PKTransferStatusQueued),
                       @(PKTransferStatusDownloading),
                       @(PKTransferStatusCompleting),
                       @(PKTransferStatusSeeding),
                       @(PKTransferStatusCompleted)];
    
    NSDictionary *titles = @{@(PKTransferStatusUnknown): NSLocalizedString(@"Unknown", nil),
                             @(PKTransferStatusError): NSLocalizedString(@"Error", nil),
                             @(PKTransferStatusQueued): NSLocalizedString(@"Queued", nil),
                             @(PKTransferStatusDownloading): NSLocalizedString(@"Downloading", nil),
                             @(PKTransferStatusCompleting): NSLocalizedString(@"Completing", nil),
                             @(PKTransferStatusSeeding): NSLocalizedString(@"Seeding", nil),
                             @(PKTransferStatusCompleted): NSLocalizedString(@"Completed", nil)};
    
    NSMutableArray *categories = [[NSMutableArray alloc] initWithCapacity:transfersDict.count];
    
    [order each:^(NSNumber *status) {
        PATransferCategory *category = [[PATransferCategory alloc] initWithTitle:titles[status]
                                                                       transfers:transfersDict[status]
                                                                      statusCode:[status integerValue]];
        
        if (category.transfers.count != 0) {
            [category sort];
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
    PATransferCategory *cateogry = [self categoryForSection:indexPath.section];
    
    if (cateogry.transfers.count > indexPath.row) {
        return cateogry.transfers[indexPath.row];
    } else {
        return nil;
    }
}

- (BOOL)isClearCompletedCell:(NSIndexPath *)indexPath;
{
    PATransferCategory *category = [self categoryForSection:indexPath.section];
    return category.statusCode == PKTransferStatusCompleted && indexPath.row == category.transfers.count;
}

- (void)addTorrent:(id)sender;
{
    [self.navigationController presentViewController:[PAAddTorrentViewController addTorrentViewControllerWithTorrentURL:nil]
                                            animated:YES
                                          completion:nil];
}

- (void)startSearch:(id)sender;
{
    [self.navigationController presentViewController:[PASearchViewController searchViewController]
                                            animated:YES
                                          completion:nil];
}


#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
    PKTransfer *tranfer = [self tranferForIndexPath:indexPath];
    [[PAPutIOController sharedController].putIOClient cancelTransfer:tranfer
                                                                    :^{
                                                                        [self reloadTransfers];
                                                                    } failure:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.transferCategories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PATransferCategory *category = [self categoryForSection:section];
    
    if (category.statusCode == PKTransferStatusCompleted) {
        return category.transfers.count + 1;
    } else {
        return category.transfers.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    return [self categoryForSection:section].title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isClearCompletedCell:indexPath]) {
        NSString *cellIdentifier = @"ClearCompletedCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            UILabel *label = [[UILabel alloc] initWithFrame:cell.frame];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            label.text = NSLocalizedString(@"Clear Finished", nil);
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = self.view.tintColor;
            [cell addSubview:label];
        }
        
        return cell;
    }
    
    PKTransfer *transfer = [self tranferForIndexPath:indexPath];
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %i", transfer.transferStatus];
    PATransferCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PATransferCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.transfer = transfer;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return [self isClearCompletedCell:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (![self isClearCompletedCell:indexPath]) return;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[PAPutIOController sharedController].putIOClient cleanFinishedTransfersCallback:^(id JSON) {
            [self reloadTransfers];
        } networkFailure:nil];
    });
}


@end
