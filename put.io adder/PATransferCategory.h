//
//  PATransferCategory.h
//  put.io adder
//
//  Created by Max Winde on 23.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PATransferCategory : NSObject

@property (strong, readonly) NSString *title;
@property (strong, readonly) NSArray *transfers;
@property (assign, readonly) PKTransferStatus statusCode;

- (id)initWithTitle:(NSString *)title transfers:(NSArray *)transfers statusCode:(PKTransferStatus)statusCode;
- (void)sort;

@end
