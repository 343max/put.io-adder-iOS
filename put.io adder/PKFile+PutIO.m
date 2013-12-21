//
//  PKFile+PutIO.m
//  put.io adder
//
//  Created by Thomas Kollbach on 11.12.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PKFile+PutIO.h"
#import "PAPutIOController.h"

@implementation PKFile (PutIO)

- (NSURL *)streamableURL;
{
    NSURL *streamURL;
    if (self.isMP4Available.boolValue) {
        streamURL = [[PAPutIOController sharedController] mp4StreamURLForFile:self];
    } else if ([self.contentType isEqualToString:@"video/mp4"]) {
        streamURL = [[PAPutIOController sharedController] streamURLForFile:self];
    }
    
    return streamURL;
}

@end
