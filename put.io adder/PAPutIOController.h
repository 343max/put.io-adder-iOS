//
//  PAPutIOController.h
//  put.io adder
//
//  Created by Max Winde on 23.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <PutioKit/V2PutIOAPIClient.h>

#import <Foundation/Foundation.h>

extern NSString * const PAPutIOControllerTransfersDidChangeNotification;

@interface PAPutIOController : NSObject

+ (PAPutIOController *)sharedController;

@property (strong, readonly) V2PutIOAPIClient *putIOClient;

@property (nonatomic, readonly) BOOL isReday;

- (UIViewController *)authenticationViewController;
- (void)downloadTorrent:(NSURL *)URL toFolder:(PKFolder *)folder;
- (BOOL)isTorrentURL:(NSURL *)URL;

@property (readonly) NSArray *transfers;
- (void)reloadTransfers:(void(^)(NSError *error))callback;

@end
