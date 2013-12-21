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

@interface PAMainViewController ()  <UIPageViewControllerDelegate, UIPageViewControllerDataSource>



@end

@implementation PAMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.delegate = self;
    self.dataSource = self;
    
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
    self.transfersController.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    self.filesController = [[PAFilesViewController alloc] initWithFolder:nil];
    self.filesController.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
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
            [self setViewControllers:@[ self.transfersController ]
                           direction:UIPageViewControllerNavigationDirectionReverse
                            animated:YES
                          completion:NULL];
            break;
            
        case PAAppSectionFiles:
            [self setViewControllers:@[ self.filesController ]
                           direction:UIPageViewControllerNavigationDirectionForward
                            animated:YES
                          completion:NULL];
    }
}

#pragma mark UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;
{
    if (viewController == self.transfersController) {
        return nil;
    } else if (viewController == self.filesController) {
        return self.transfersController;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;
{
    if (viewController == self.transfersController) {
        return self.filesController;
    } else if (viewController == self.filesController) {
        return nil;
    }
    
    return nil;
}

- (NSUInteger)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed;
{
    if (self.viewControllers.firstObject == self.filesController) {
        self.sectionPicker.selectedSegmentIndex = PAAppSectionFiles;
    } else if (self.viewControllers.firstObject == self.transfersController) {
        self.sectionPicker.selectedSegmentIndex = PAAppSectionTransfers;
    }
}


@end
