//
//  PAFileViewController.h
//  put.io adder
//
//  Created by Thomas Kollbach on 07.09.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKFile;


@interface PAFileViewController : UIViewController

+ (UIViewController *)fileTorrentViewControllerWithFile:(PKFile *)file;

- (instancetype)initWithFile:(PKFile *)file;

@property (nonatomic, readonly) PKFile *file;

@end
