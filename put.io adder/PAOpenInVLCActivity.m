//
//  PAOpenInVLCActivity.m
//  put.io adder
//
//  Created by Thomas Kollbach on 11.12.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <PutioKit/PKFile.h>
#import "NSURL+PutIO.h"


#import "PAOpenInVLCActivity.h"

@interface PAOpenInVLCActivity ()

@property PKFile *file;

@end

@implementation PAOpenInVLCActivity

- (NSString *)activityType;
{
    return @"openInVLC";
}

- (UIImage *)activityImage;
{
    return [UIImage imageNamed:@"Video"];
}

- (NSString *)activityTitle;
{
    return NSLocalizedString(@"Open in VLC", nil);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems;
{
    NSURL *url;
    for (id item in activityItems) {
        if ([item isKindOfClass:[PKFile class]]) {
            PKFile *file = item;
            
            break;
        }
    }
    return (url != nil && [[UIApplication sharedApplication] canOpenURL:url.vlcURL]);
}

- (void)prepareWithActivityItems:(NSArray *)activityItems;
{
    for (id item in activityItems) {
        if ([item isKindOfClass:[PKFile class]]) {
            break;
        }
    }
}

- (void)performActivity;
{
//    BOOL result = [[UIApplication sharedApplication] openURL:self.file.vlcURL];
    
//    [self activityDidFinish:result];
}

@end
