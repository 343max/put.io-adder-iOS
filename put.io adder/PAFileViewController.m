//
//  PAFileViewController.m
//  put.io adder
//
//  Created by Thomas Kollbach on 07.09.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <BlocksKit/BlocksKit.h>
#import <PutioKit/PKFile.h>
#import <MediaPlayer/MediaPlayer.h>

#import "PAPutIOController.h"
#import "PAFileViewController.h"

@interface PAFileViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong) MPMoviePlayerController *playerController;

@end

@implementation PAFileViewController

+ (UIViewController *)fileTorrentViewControllerWithFile:(PKFile *)file;
{
    PAFileViewController *viewController = [[PAFileViewController alloc] initWithFile:file];
    return [[UINavigationController alloc] initWithRootViewController:viewController];
}

- (instancetype)initWithFile:(PKFile *)file;
{
    NSParameterAssert(file);
    self = [super initWithNibName:@"PAFileViewController" bundle:nil];
    if (self) {
        _file = file;

        __weak PAFileViewController *weakSelf = self;
        [_file addObserverForKeyPaths:@[ @"name", @"screenshot", @"isMP4Available" ]
                          identifier:@"foobar"
                             options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial
                                task:^(PKFile *obj, NSString *keyPath, NSDictionary *change) {
                                    weakSelf.title = obj.name;
                                    if (obj.hasPreviewThumbnail) {
                                        NSURL *url = [NSURL URLWithString:obj.screenshot];
                                        [weakSelf.imageView setImageWithURL:url];
                                    }
                                    
                                }];
    }
    return self;
}

- (void)dealloc;
{
    [_file removeObserversWithIdentifier:@"foobar"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerLoadStateDidChangeNotification
                                                  object:nil];
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerLoadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    
    if (self.isBeingPresented) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                             handler:^(id sender) {
                                                                                                 [self dismissViewControllerAnimated:YES completion:NULL];
                                                                                             }];
        
    }
    
    NSURL *streamURL;
    if (self.file.isMP4Available.boolValue) {
        streamURL = [[PAPutIOController sharedController] mp4StreamURLForFile:self.file];
    } else if ([self.file.contentType isEqualToString:@"video/mp4"]) {
        streamURL = [[PAPutIOController sharedController] streamURLForFile:self.file];
    }
    
    
    if (streamURL) {
        NSLog(@"url = %@", streamURL);
        self.playerController = [[MPMoviePlayerController alloc] initWithContentURL:streamURL];
        self.playerController.controlStyle = MPMovieControlStyleEmbedded;
        self.playerController.shouldAutoplay = NO;
        self.playerController.allowsAirPlay = YES;
        [self.playerController prepareToPlay];
        self.playerController.view.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame),
                                                      CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) / 16.0 * 9.0);
        self.playerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        
        [self.view addSubview:self.playerController.view];
        
        [self.playerController play];

    } else {
        [[[UIAlertView alloc] initWithTitle:@"No MP4" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}


#pragma mark Notifications

- (void)playerStateDidChange:(NSNotification *)notification;
{
    NSLog(@"%s: %d", __PRETTY_FUNCTION__, self.playerController.playbackState);
}

- (void)playerLoadStateDidChange:(NSNotification *)notification;
{
    NSLog(@"%s: %d", __PRETTY_FUNCTION__, self.playerController.loadState);
}
                                            
@end
