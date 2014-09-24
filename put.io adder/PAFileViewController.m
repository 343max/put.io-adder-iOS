//
//  PAFileViewController.m
//  put.io adder
//
//  Created by Thomas Kollbach on 07.09.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <BlocksKit/BlocksKit+UIKit.h>
#import <PutioKit/PKFile.h>
#import <MediaPlayer/MediaPlayer.h>

#import "NSURL+PutIO.h"
#import "PAFileView.h"
#import "PAPutIOController.h"
#import "PAFileViewController.h"
#import "PAMP4ConversionView.h"

@interface PAFileViewController ()

@property PAFileView *fileView;
@property MPMoviePlayerController *playerController;
@property UIActivityIndicatorView *spinner;
@property (nonatomic) BOOL isPlaying;
@property NSTimer *currentPlaybackTimeTimer;

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
        [_file bk_addObserverForKeyPaths:@[ @"name", @"screenshot", @"isMP4Available" ]
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
    [_file bk_removeObserversWithIdentifier:@"foobar"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerLoadStateDidChangeNotification
                                                  object:nil];
}

#pragma mark UIViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
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
    
    
    if (self.navigationController.viewControllers.firstObject == self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                             handler:^(id sender) {
                                                                                                 [self dismissViewControllerAnimated:YES completion:NULL];
                                                                                             }];
        
    }

    [self updateUI];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    
    [self.playerController stop];
}


#pragma mark Notifications

- (void)playerStateDidChange:(NSNotification *)notification;
{
    NSLog(@"%s: %d", __PRETTY_FUNCTION__, self.playerController.playbackState);
    
    if (self.playerController.loadState == MPMoviePlaybackStatePlaying) {
        [self.spinner stopAnimating];
        self.isPlaying = YES;
    } else {
        self.isPlaying = NO;
    }

    NSError *error;
    
    switch (self.playerController.playbackState) {
        case MPMoviePlaybackStateStopped:
            [[AVAudioSession sharedInstance] setActive:NO
                                                 error:&error];
             [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
            [self resignFirstResponder];
            
            [self.currentPlaybackTimeTimer invalidate];
            self.currentPlaybackTimeTimer = nil;
            
            break;
            
        case MPMoviePlaybackStatePlaying:
        
            if (!self.currentPlaybackTimeTimer) {
                __weak id blockSelf = self;
                [self.currentPlaybackTimeTimer invalidate];
                self.currentPlaybackTimeTimer = [NSTimer bk_scheduledTimerWithTimeInterval:1.0
                                                                                  block:^(NSTimer *timer) {
                                                                                      [blockSelf updateNowPlayingInfo];
                                                                                  }
                                                                                repeats:YES];
                
            }
            
            
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            [self becomeFirstResponder];
            
            
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                                   error:&error];
            NSAssert(error == nil, error.localizedDescription);
            
            [[AVAudioSession sharedInstance] setActive:YES
                                                 error:&error];
            NSAssert(error == nil, error.localizedDescription);
            
            break;
        
        default:
            break;
    }
    
    [self updateNowPlayingInfo];
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
    [self updateMP4Status];
    
    
    NSURL *streamURL;
    if (self.file.isMP4Available.boolValue) {
        streamURL = [[PAPutIOController sharedController] mp4StreamURLForFile:self.file];
    } else if ([self.file.contentType isEqualToString:@"video/mp4"]) {
        streamURL = [[PAPutIOController sharedController] streamURLForFile:self.file];
    }
    
    if (streamURL) {
        NSLog(@"url = %@", streamURL);
        
        if ([[UIApplication sharedApplication] canOpenURL:streamURL.vlcURL]) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:NSLocalizedString(@"Open in VLC", nil)
                                                                                      style:UIBarButtonItemStylePlain
                                                                                    handler:^(id sender) {
                                                                                        NSLog(@"opening in VLC: %@", streamURL.vlcURL);
                                                                                        [[UIApplication sharedApplication] openURL:streamURL.vlcURL];
                                                                                    }];
        }
        
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

- (void)updateMP4Status;
{
    @weakify(self);
    [[PAPutIOController sharedController] updateMP4StatusForFile:self.file
                                                        callback:^(PKMP4Status *status, NSError *error) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                @strongify(self);
                                                                
                                                                self.fileView.conversionView.mp4Status = status;
                                                                
                                                                if (error) [self presentError:error];
                                                            });
                                                        }];
}

- (void)updateNowPlayingInfo;
{
    NSMutableDictionary *nowPlayingInfo;
    
    if (self.playerController.playbackState != MPMoviePlaybackStateStopped) {
        nowPlayingInfo = [NSMutableDictionary dictionary];
        if (self.file.name) nowPlayingInfo[MPMediaItemPropertyTitle] = self.file.name;
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(self.playerController.currentPlaybackTime);
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = @(self.playerController.duration);
    }
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingInfo];
}


#pragma mark Remote Control Events

- (IBAction)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent;
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            case UIEventSubtypeRemoteControlPlay:
            case UIEventSubtypeRemoteControlStop:
            case UIEventSubtypeRemoteControlPause:
                
                [self togglePlayback:receivedEvent];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self jumpBack:receivedEvent];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self jumpForward: nil];
                break;
                
            default:
                break;
        }
    }
}

- (void)presentError:(NSError *)error;
{
    if (error) {
        [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Error", nil)
                                    message:error.localizedDescription
                          cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                          otherButtonTitles:@[]
                                    handler:NULL];
    }
}

#pragma mark Actions

- (BOOL)canBecomeFirstResponder;
{
    return YES;
}

- (IBAction)togglePlayback:(id)sender;
{
    switch (self.playerController.playbackState) {
        case MPMoviePlaybackStatePaused:
        case MPMoviePlaybackStateStopped:
            [self.playerController play];
            break;
            
        default:
            [self.playerController pause];
            break;
    }
}

- (IBAction)jumpForward:(id)sender;
{
    if (self.playerController.playbackState != MPMoviePlaybackStateStopped) {
        self.playerController.currentPlaybackTime += 10;
    } else {
        self.playerController.initialPlaybackTime += 10;
    }
}

- (IBAction)jumpBack:(id)sender;
{
    if (self.playerController.playbackState != MPMoviePlaybackStateStopped) {
        self.playerController.currentPlaybackTime -= 10;
    } else {
        self.playerController.initialPlaybackTime -= 10;
    }
}

@end