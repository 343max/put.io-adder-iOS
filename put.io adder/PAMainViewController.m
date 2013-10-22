//
//  PAMainViewController.m
//  put.io adder
//
//  Created by Thomas Kollbach on 08.09.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PAAddTorrentViewController.h"
#import "PASearchViewController.h"

#import "PATransfersViewController.h"
#import "PAFilesViewController.h"

#import "PAMainViewController.h"

enum PAAppSection {
    PAAppSectionTransfers = 0,
    PAAppSectionFiles = 1
};


@interface PAMainViewController ()

@end

@implementation PAMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addTorrent:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                          target:self
                                                                                          action:@selector(startSearch:)];

    self.sectionPicker = [[UISegmentedControl alloc] initWithItems:@[ NSLocalizedString(@"Transfers", nil),
                                                                      NSLocalizedString(@"Files", nil) ]];
    self.sectionPicker.selectedSegmentIndex = 0;
    [self.sectionPicker addTarget:self
                           action:@selector(switchSetion:)
                 forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.sectionPicker;
    
    self.transfersController = [[PATransfersViewController alloc] initWithStyle:UITableViewStylePlain];
    self.transfersController.view.frame = self.view.bounds;
    [self addChildViewController:self.transfersController];
    [self.transfersController didMoveToParentViewController:self];
    
    self.filesController = [[PAFilesViewController alloc] initWithFolder:nil];
    self.filesController.view.frame = self.view.bounds;
    [self addChildViewController:self.filesController];
    [self.filesController didMoveToParentViewController:self];
    
    [self switchSetion:self.sectionPicker];
}


#pragma mark Actions

- (IBAction)addTorrent:(id)sender;
{
    UIViewController *controller = [PAAddTorrentViewController addTorrentViewControllerWithTorrentURL:nil];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:controller
                                            animated:YES
                                          completion:nil];
}

- (IBAction)startSearch:(id)sender;
{
    UIViewController *controller = [PASearchViewController searchViewController];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:controller
                                            animated:YES
                                          completion:nil];
}

- (IBAction)switchSetion:(UISegmentedControl *)sender;
{
    switch (sender.selectedSegmentIndex) {
        case PAAppSectionTransfers:
            [self.filesController.view removeFromSuperview];
            [self.view addSubview:self.transfersController.view];
            [self.transfersController.tableView flashScrollIndicators];
            break;
            
        case PAAppSectionFiles:
            [self.transfersController.view removeFromSuperview];
            [self.view addSubview:self.filesController.view];
            [self.filesController.tableView flashScrollIndicators];
            break;
    }
    
    self.filesController.tableView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame), 0, 0, 0);
    self.transfersController.tableView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame), 0, 0, 0);
    
    self.filesController.tableView.scrollIndicatorInsets = self.filesController.tableView.contentInset;
    self.transfersController.tableView.scrollIndicatorInsets = self.transfersController.tableView.contentInset;
}

@end
