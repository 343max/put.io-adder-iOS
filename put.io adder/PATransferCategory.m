//
//  PATransferCategory.m
//  put.io adder
//
//  Created by Max Winde on 23.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <PutioKit/PKTransfer.h>

#import "PATransferCategory.h"

@implementation PATransferCategory

- (id)initWithTitle:(NSString *)title transfers:(NSArray *)transfers statusCode:(PKTransferStatus)statusCode;
{
    self = [super init];
    
    if (self) {
        _title = title;
        _transfers = transfers;
        _statusCode = statusCode;
    }
    
    return self;
}

- (void)sort;
{
    _transfers = [self.transfers sortedArrayUsingComparator:^NSComparisonResult(PKTransfer *obj1, PKTransfer *obj2) {
        return [obj2.createdAt compare:obj1.createdAt];
    }];
}

@end
