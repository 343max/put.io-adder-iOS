//
//  PATransfersViewController.m
//  put.io adder
//
//  Created by Max Winde on 23.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PAPutIOController.h"

#import "PATransfersViewController.h"

@interface PATransfersViewController ()

@property (strong, nonatomic) NSArray *transfers;

- (void)reloadTransfers;
- (PKTransfer *)tranferForIndexPath:(NSIndexPath *)indexPath;

@end

@implementation PATransfersViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"Transfers", @"Transfers View Controller Title");
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
    [self reloadTransfers];
}

- (void)reloadTransfers;
{
    V2PutIOAPIClient *client = [PAPutIOController sharedController].putIOClient;
    
    if (client.ready == NO) return;
    
    [client getTransfers:^(NSArray *transfers) {
        self.transfers = transfers;
    } failure:^(NSError *error) {
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
    
    [self.tableView reloadData];
}

- (PKTransfer *)tranferForIndexPath:(NSIndexPath *)indexPath;
{
    return self.transfers[indexPath.row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.transfers.count;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
