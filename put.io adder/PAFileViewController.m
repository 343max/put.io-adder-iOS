//
//  PAFileViewController.m
//  put.io adder
//
//  Created by Thomas Kollbach on 07.09.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <PutioKit/PKFile.h>

#import "PAFileViewController.h"

@interface PAFileViewController ()

@end

@implementation PAFileViewController

+ (UIViewController *)fileTorrentViewControllerWithFile:(PKFile *)file;
{
    PAFileViewController *viewController = [[PAFileViewController alloc] initWithFile:file];
    return [[UINavigationController alloc] initWithRootViewController:viewController];
}

- (instancetype)initWithFile:(PKFile *)file;
{
    NSParameterAssert(file);
    self = [super initWithNibName:@"PAFileViewController" bundle:nil];
    if (self) {
        _file = file;
    }
    return self;
}
                                            
@end
