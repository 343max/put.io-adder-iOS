//
//  PAAddTorrentViewController.h
//  put.io adder
//
//  Created by Max Winde on 25.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKFolder;

@interface PAAddTorrentViewController : UITableViewController

+ (UIViewController *)addTorrentViewControllerWithTorrentURL:(NSURL *)torrentURL;

- (id)initWithTorrentURL:(NSURL *)torrentURL;

@property (strong, nonatomic) PKFolder *selectedFolder;

@end
