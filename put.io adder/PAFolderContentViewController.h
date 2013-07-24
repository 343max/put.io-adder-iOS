//
//  PAFolderContentViewController.h
//  put.io adder
//
//  Created by Max Winde on 25.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAFolderContentViewController : UITableViewController

- (id)initWithFolderIdentifier:(NSString *)folderIdentifier showFoldersOnly:(BOOL)showFoldersOnly;

@property (strong, readonly) NSString *folderIdentifier;
@property (assign, readonly) BOOL showFoldersOnly;

@end
