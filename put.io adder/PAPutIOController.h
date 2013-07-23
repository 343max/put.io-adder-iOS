//
//  PAPutIOController.h
//  put.io adder
//
//  Created by Max Winde on 23.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <PutioKit/V2PutIOAPIClient.h>

#import <Foundation/Foundation.h>

@interface PAPutIOController : NSObject

+ (PAPutIOController *)sharedController;

@property (strong, readonly) V2PutIOAPIClient *putIOClient;

- (UIViewController *)authenticationViewController;

@end
