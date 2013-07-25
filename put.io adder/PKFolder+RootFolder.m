//
//  PKFolder+RootFolder.m
//  put.io adder
//
//  Created by Max Winde on 25.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PKFolder+RootFolder.h"

@implementation PKFolder (RootFolder)

+ (PKFolder *)rootFolder;
{
    static PKFolder *rootFolder;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rootFolder = [[PKFolder alloc] init];
        rootFolder.name = NSLocalizedString(@"Your Files", @"Root Folder Name");
        rootFolder.id = @"0";
        rootFolder.numberOfParentFolders = -1;
    });
    
    return rootFolder;
}

@end
