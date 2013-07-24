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

- (void)reloadTransfers;
- (PKTransfer *)tranferForIndexPath:(NSIndexPath *)indexPath;
- (PATransferCategory *)categoryForSection:(NSInteger)section;

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

- (void)reloadTransfers;
{
    [self.refreshControl beginRefreshing];
    
    V2PutIOAPIClient *client = [PAPutIOController sharedController].putIOClient;
    
    if (client.ready == NO) return;
    
    [client getTransfers:^(NSArray *transfers) {
        self.transfers = transfers;
        
        [self.refreshControl endRefreshing];
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
    
    NSDictionary *titles = @{@(PKTransferStatusUnknown): NSLocalizedString(@"Unknown", nil),
                             @(PKTransferStatusError): NSLocalizedString(@"Error", nil),
                             @(PKTransferStatusDownloading): NSLocalizedString(@"Downloading", nil),
                             @(PKTransferStatusSeeding): NSLocalizedString(@"Seeding", nil),
                             @(PKTransferStatusCompleted): NSLocalizedString(@"Completed", nil)};
    
    NSMutableArray *categories = [[NSMutableArray alloc] initWithCapacity:transfersDict.count];
    
    [titles each:^(NSNumber *status, NSString *title) {
       PATransferCategory *category = [[PATransferCategory alloc] initWithTitle:title
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



@end
