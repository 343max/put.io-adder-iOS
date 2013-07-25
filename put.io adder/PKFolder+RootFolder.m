//
//  PKFolder+RootFolder.m
//  put.io adder
//
//  Created by Max Winde on 25.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <NSObject+Expectation/NSObject+Expectation.h>

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

+ (PKFolder *)folderWithDictionary:(NSDictionary *)dictionary;
{
    if ([dictionary[@"name"] nilUnlessKindOfClass:[NSString class]] == nil ||
        [dictionary[@"identifier"] nilUnlessKindOfClass:[NSString class]] == nil)
        return  nil;
    
    if ([dictionary[@"identifer"] isEqualToString:[PKFolder rootFolder].id]) return [PKFolder rootFolder];
    
    PKFolder *folder = [[PKFolder alloc] init];
    folder.id = dictionary[@"identifier"];
    folder.name = dictionary[@"name"];
    return folder;
}

- (NSDictionary *)dictionary;
{
    return @{ @"name": self.name, @"identifier": self.id };
}

@end
