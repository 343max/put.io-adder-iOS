//
//  UIActivityViewController+PutIO.m
//  put.io adder
//
//  Created by Thomas Kollbach on 11.12.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <PutioKit/PKFile.h>

#import "PAOpenInVLCActivity.h"
#import "UIActivityViewController+PutIO.h"

@implementation UIActivityViewController (PutIO)

+ (instancetype)activitiyViewControllerForFile:(PKFile *)file;
{
    NSArray *items = @[ file ];
    NSArray *activities = @[  ];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                             applicationActivities:activities];
    
    return controller;
}

@end
