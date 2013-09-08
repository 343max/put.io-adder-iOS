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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addTorrent:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                          target:self
                                                                                          action:@selector(startSearch:)];

    self.sectionPicker = [[UISegmentedControl alloc] initWithItems:@[ @"Transfers", @"Files" ]];
    self.sectionPicker.selectedSegmentIndex = 0;
    [self.sectionPicker addTarget:self
                           action:@selector(switchSetion:)
                 forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.sectionPicker;
    
    self.transfersController = [[PATransfersViewController alloc] initWithStyle:UITableViewStylePlain];
    self.transfersController.view.frame = self.view.bounds;
    [self.view addSubview:self.transfersController.view];
    [self addChildViewController:self.transfersController];
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
            self.transfersController.view.hidden = NO;
            break;
            
        case PAAppSectionFiles:
            self.transfersController.view.hidden = YES;
            break;
    }

    [self.transfersController.tableView setContentOffset:CGPointZero animated:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.transfersController.tableView flashScrollIndicators];
    });
}

@end
