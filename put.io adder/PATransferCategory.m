//
//  PATransferCategory.m
//  put.io adder
//
//  Created by Max Winde on 23.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PATransferCategory.h"

@implementation PATransferCategory

- (id)initWithTitle:(NSString *)title transfers:(NSArray *)transfers;
{
    self = [super init];
    
    if (self) {
        _title = title;
        _transfers = transfers;
    }
    
    return self;
}

@end
