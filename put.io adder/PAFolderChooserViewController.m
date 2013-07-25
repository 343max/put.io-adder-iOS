//
//  PAFolderChooserViewController.m
//  put.io adder
//
//  Created by Max Winde on 25.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PAFolderChooserTableViewController.h"

#import "PAFolderChooserViewController.h"

@interface PAFolderChooserViewController ()

@property (strong) PAFolderChooserTableViewController *viewController;

@end

@implementation PAFolderChooserViewController

+ (UIViewController *)folderChooserViewController;
{
    PAFolderChooserTableViewController *viewController = [[PAFolderChooserTableViewController alloc] initWithStyle:UITableViewStylePlain];
    PAFolderChooserViewController *navigationViewController = [[PAFolderChooserViewController alloc] initWithRootViewController:viewController];
    return navigationViewController;
}

@end
