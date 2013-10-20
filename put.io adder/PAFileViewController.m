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

#import "PAFileView.h"
#import "PAPutIOController.h"
#import "PAFileViewController.h"

@interface PAFileViewController ()

@property (strong) PAFileView *fileView;
@property (strong) MPMoviePlayerController *playerController;
@property (strong) UIActivityIndicatorView *spinner;

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
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _file = file;

        __weak PAFileViewController *weakSelf = self;
        [_file addObserverForKeyPaths:@[ @"name", @"screenshot", @"isMP4Available" ]
                          identifier:@"foobar"
                             options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial
                                task:^(PKFile *obj, NSString *keyPath, NSDictionary *change) {
                                    [weakSelf updateUI];
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
    
    self.fileView = [[PAFileView alloc] initWithFrame:self.view.bounds];
    self.fileView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.fileView];
    
    
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

    [self updateUI];
}


#pragma mark Notifications

- (void)playerStateDidChange:(NSNotification *)notification;
{
    if (self.playerController.loadState == MPMoviePlaybackStatePlaying) {
        [self.spinner stopAnimating];
    }
    NSLog(@"%s: %d", __PRETTY_FUNCTION__, self.playerController.playbackState);
}

- (void)playerLoadStateDidChange:(NSNotification *)notification;
{
    switch (self.playerController.loadState) {
        case MPMovieLoadStateUnknown:
        case MPMovieLoadStateStalled:
            [self.spinner startAnimating];
            break;
            
        default:
            [self.spinner stopAnimating];
            break;
    }
    NSLog(@"%s: %d", __PRETTY_FUNCTION__, self.playerController.loadState);
}


#pragma mark Update UI

- (void)updateUI;
{
    self.title = self.file.name;
    self.fileView.titleLabel.text = self.title;
    
    NSURL *streamURL;
    if (self.file.isMP4Available.boolValue) {
        streamURL = [[PAPutIOController sharedController] mp4StreamURLForFile:self.file];
    } else if ([self.file.contentType isEqualToString:@"video/mp4"]) {
        streamURL = [[PAPutIOController sharedController] streamURLForFile:self.file];
    }
    
    if (streamURL) {
        NSLog(@"url = %@", streamURL);
        if (!self.playerController) {
            self.playerController = [[MPMoviePlayerController alloc] initWithContentURL:streamURL];
            self.playerController.controlStyle = MPMovieControlStyleEmbedded;
            self.playerController.shouldAutoplay = NO;
            self.playerController.allowsAirPlay = YES;
            
            self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            self.spinner.frame = self.playerController.backgroundView.frame;
            self.spinner.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            self.spinner.userInteractionEnabled = NO;
            [self.playerController.view addSubview:self.spinner];
            self.spinner.hidesWhenStopped = YES;
            [self.spinner startAnimating];
            
            [self.playerController prepareToPlay];

        } else {
            self.playerController.contentURL = streamURL;
        }
        
        if (self.playerController.view.superview != self.fileView.viedoPlayerContainerView) {
            self.playerController.view.frame = self.fileView.viedoPlayerContainerView.bounds;
            self.playerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            [self.fileView.viedoPlayerContainerView addSubview:self.playerController.view];
        }

        self.fileView.headerImageView.hidden = YES;
        self.fileView.viedoPlayerContainerView.hidden = NO;
    } else {
        self.fileView.headerImageView.hidden = NO;
        self.fileView.viedoPlayerContainerView.hidden = YES;
        
        if (self.file.hasPreviewThumbnail) {
            NSURL *url = [NSURL URLWithString:self.file.screenshot];
            [self.fileView.headerImageView setImageWithURL:url];
        }
    }
    
    [self.fileView setNeedsLayout];    
}


@end
