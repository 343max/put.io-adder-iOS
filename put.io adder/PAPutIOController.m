//
//  PAPutIOController.m
//  put.io adder
//
//  Created by Max Winde on 23.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <PutioKit/PutIONetworkConstants.h>

#import "PAPutIOController.h"

NSString * const PAPutIOControllerTransfersDidChangeNotification = @"PAPutIOControllerTransfersDidChangeNotification";
NSString * const PAPutIOControllerFilesAndFoldersDidReloadNotification = @"PAPutIOControllerFilesAndFoldersDidReloadNotification";

@interface PAPutIOController ()

@property (readwrite) NSArray *transfers;
@property (readwrite) NSArray *folders;
@property (readwrite) NSArray *files;

@end

@implementation PAPutIOController

+ (PAPutIOController *)sharedController;
{
    static PAPutIOController *sharedController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[PAPutIOController alloc] init];
    });
    
    return sharedController;
}

- (id)init;
{
    self = [super init];
    
    if (self) {
        _putIOClient = [V2PutIOAPIClient setup];
        _files = @[];
        _folders = @[];
        _transfers = @[];
    }
    
    return self;
}

- (UIViewController *)authenticationViewController;
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = NSLocalizedString(@"log in to put.io", @"authentication view controller title");
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:viewController.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [viewController.view addSubview:webView];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [webView setShouldStartLoadBlock:^BOOL(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType) {
        NSURL *URL = request.URL;
        
        if ([URL.host isEqualToString:@"localhost"]) {
            self.putIOClient.apiToken = [URL.fragment substringFromIndex:13];
            [[NSUserDefaults standardUserDefaults] setObject:self.putIOClient.apiToken forKey:PKAppAuthTokenDefault];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [navigationController dismissViewControllerAnimated:YES completion:nil];
            return NO;
        }

        return YES;
    }];
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.put.io/v2/oauth2/authenticate?client_id=741&response_type=token&redirect_uri=http://localhost/"]]];
    
    return navigationController;
}

- (void)downloadTorrent:(NSURL *)URL toFolder:(PKFolder *)folder
{
    void(^onComplete)(id userInfoObject) = ^(id userInfoObject) {
        NSLog(@"complete: %@", userInfoObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPutIOControllerTransfersDidChangeNotification
                                                            object:nil];
    };
    
    void(^onAddFailure)(void) = ^(void) {
#warning totaly incomplete
        NSLog(@"something did go wrong");
    };
    
    void(^onNetworkFailure)(NSError *error) = ^(NSError *error) {
#warning incomplete
        NSLog(@"network error: %@", error);

    };
    
    if ([URL isFileURL]) {
        [self.putIOClient uploadFile:URL.path
                            toFolder:folder
                            callback:onComplete
                          addFailure:onAddFailure
                      networkFailure:onNetworkFailure];
    } else {
        [self.putIOClient requestTorrentOrMagnetURL:URL
                                           toFolder:folder
                                           callback:onComplete
                                         addFailure:onAddFailure
                                     networkFailure:onNetworkFailure];
    }
}

- (BOOL)isTorrentURL:(NSURL *)URL;
{
    return [URL.scheme isEqualToString:@"magnet"] || [URL.scheme isEqualToString:@"http"] || [URL.scheme isEqualToString:@"https"];
}


#pragma mark Accessors

- (BOOL)isReday;
{
    return self.putIOClient.ready;
}

- (void)reloadTransfers:(void(^)(NSError *error))callback;
{
    [self.putIOClient getTransfers:^(NSArray *transfers) {
        self.transfers = transfers;
        
        if (callback) callback(nil);
    } failure:^(NSError *error) {
        if (callback) callback(error);
    }];
}

- (void)reloadFilesAndFolders:(void(^)(NSError *error))callback;
{
    PKFolder *folder = [[PKFolder alloc] init];
    folder.id = @"-1";
    
    [[PAPutIOController sharedController].putIOClient getFolderItems:folder
                                                                    :^(NSArray *filesAndFolders)
     {
         NSMutableArray *folders = [NSMutableArray array];
         NSMutableArray *files = [NSMutableArray array];
         
         [filesAndFolders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             if ([obj isKindOfClass:[PKFolder class]]) {
                 [folders addObject:obj];
             } else if ([obj isKindOfClass:[PKFile class]]) {
                 [files addObject:obj];
             }
         }];
         
         self.folders = folders;
         self.files = files;
         
         if (callback) callback(nil);
     }
                                                             failure:^(NSError *error)
     {
#warning handle the error!
         NSLog(@"error: %@", error);
         if (callback) callback(error);
     }];
}

- (void)fileForTransfer:(PKTransfer *)transfer callback:(void(^)(PKFile *file, NSError *error))callback;
{
    if ((id)transfer.fileID == [NSNull null]) {
        return;
    }
    
    
    PKFile *file = [[PKFile alloc] init];
    file.id = transfer.fileID;
    [self.putIOClient getAdditionalInfoForFile:file :^{
        if (![self.files containsObject:file]) {
            self.files = [self.files arrayByAddingObject:file];
        }
        if (callback) callback(file, nil);
    } failure:^(NSError *error) {
        if (callback) callback(nil, error);
    }];

}

- (NSURL *)mp4URLForFile:(PKFile *)file;
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.put.io/v2/files/%@/mp4?oauth_token=%@", file.id, self.putIOClient.apiToken]];
}

- (NSURL *)downloadURLForFile:(PKFile *)file;
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.put.io/v2/files/%@/download?oauth_token=%@", file.id, self.putIOClient.apiToken]];
}

- (NSURL *)streamURLForFile:(PKFile *)file;
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.put.io/v2/files/%@/stream?oauth_token=%@", file.id, self.putIOClient.apiToken]];
}

- (NSURL *)mp4StreamURLForFile:(PKFile *)file;
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.put.io/v2/files/%@/mp4/stream?oauth_token=%@", file.id, self.putIOClient.apiToken]];
}

@end
