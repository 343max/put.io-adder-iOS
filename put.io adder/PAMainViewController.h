//
//  PAMainViewController.h
//  put.io adder
//
//  Created by Thomas Kollbach on 08.09.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PATransfersViewController;
@class PAFilesViewController;


@interface PAMainViewController : UIViewController

@property UISegmentedControl *sectionPicker;

@property PATransfersViewController *transfersController;
@property PAFilesViewController *filesController;

@end
