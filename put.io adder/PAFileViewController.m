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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

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
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    if (self.isBeingPresented) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                             handler:^(id sender) {
                                                                                                 [self dismissViewControllerAnimated:YES completion:NULL];
                                                                                             }];
        
    }
    


    NSURL *url = [[PAPutIOController sharedController] streamURLForFile:self.file];
    NSLog(@"url = %@", url);
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    player.controlStyle = MPMovieControlStyleEmbedded;
    player.shouldAutoplay = YES;
    [player prepareToPlay];
    player.view.frame = CGRectMake(0, 54, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) / 2);
    player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:player.view];
        [player play];
        

}
                                            
@end
