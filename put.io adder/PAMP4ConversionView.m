//
//  PAMP4ConversionView.m
//  put.io adder
//
//  Created by Thomas Kollbach on 22.12.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <BlocksKit/BlocksKit.h>
#import "PAMP4ConversionView.h"

@interface PAMP4ConversionView ()

@property NSString *KVOToken;
@property UIButton *button;
@property UIProgressView *progressBar;

@end

@implementation PAMP4ConversionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_button];
        
        _progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressBar.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_progressBar];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[button]-|"
                                                                     options:0
                                                                     metrics:@{}
                                                                       views:@{ @"button": self.button }]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[bar]-|"
                                                                     options:0
                                                                     metrics:@{}
                                                                       views:@{ @"bar": self.progressBar }]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[button]-[bar]|"
                                                                     options:0
                                                                     metrics:@{}
                                                                       views:@{ @"button": self.button,
                                                                                @"bar": self.progressBar }]];
        
    }
    return self;
}

- (void)dealloc;
{
    [self unsubscribeKVO];
}

- (void)setMp4Status:(PKMP4Status *)mp4Status;
{
    if (_mp4Status == mp4Status) return;
    
    [self unsubscribeKVO];
    
    _mp4Status = mp4Status;
    
    [self subscribeKVO];
}

- (void)unsubscribeKVO;
{
    if (self.KVOToken) {
        [self bk_removeObserversWithIdentifier:self.KVOToken];
    }
}

- (void)subscribeKVO;
{
    NSAssert([NSThread isMainThread], @"%s of %@ may not be called on a background thread", __PRETTY_FUNCTION__, self);
    
    [self unsubscribeKVO];
    
    __weak id blockSelf = self;
    self.KVOToken = [self bk_addObserverForKeyPaths:@[ @"mp4Status.mp4Status",
                                                    @"progress" ]
                                         options:NSKeyValueObservingOptionInitial
                                            task:^(id obj, NSString *keyPath, NSDictionary *change) {
                                                [blockSelf updateUI];
                                            }];
}

- (void)updateUI;
{
    [self.button setTitle:[self localizedButtonTitleForStatus:self.mp4Status.mp4Status]
                 forState:UIControlStateNormal];
    
    self.button.tintColor = [self tintColorForStatus:self.mp4Status.mp4Status];
    
    self.progressBar.progress = ([self.mp4Status.progress floatValue] / 100.0);
}

- (NSString *)localizedButtonTitleForStatus:(PKMP4StatusType)status;
{
    switch (status) {
        case PKMP4StatusConverting:
        case PKMP4StatusQueued:
            return NSLocalizedString(@"Cancel", nil);
            
        case PKMP4StatusUnknown:
        case PKMP4StatusNotAvailable:
            return NSLocalizedString(@"Start", nil);
            
        case PKMP4StatusCompleted:
            return NSLocalizedString(@"Remove MP4", nil);
    }
    
    return nil;
}

- (UIColor *)tintColorForStatus:(PKMP4StatusType)status;
{
    switch (status) {
        case PKMP4StatusConverting:
        case PKMP4StatusQueued:
        case PKMP4StatusCompleted:
            return [UIColor redColor];
            
        default:
            return self.tintColor ?: self.window.tintColor;
    }
}

@end
