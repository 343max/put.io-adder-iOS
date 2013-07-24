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

- (id)initWithTitle:(NSString *)title transfers:(NSArray *)transfers;
- (void)sort;

@end
