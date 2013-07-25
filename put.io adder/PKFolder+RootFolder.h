//
//  PKFolder+RootFolder.h
//  put.io adder
//
//  Created by Max Winde on 25.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PKFolder.h"

@interface PKFolder (RootFolder)

+ (PKFolder *)rootFolder;
+ (PKFolder *)folderWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionary;

@end
