//
//  NSURL+PutIO.m
//  put.io adder
//
//  Created by Thomas Kollbach on 11.12.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "NSURL+PutIO.h"

@implementation NSURL (PutIO)

- (NSURL *)vlcURL;
{
    NSString *vlcURLString = [NSString stringWithFormat:@"vlc://%@", self.absoluteString];
    return [NSURL URLWithString:vlcURLString];
}

@end
