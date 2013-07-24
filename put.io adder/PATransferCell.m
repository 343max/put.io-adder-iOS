//
//  PATransferCell.m
//  put.io adder
//
//  Created by Max Winde on 24.07.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "LSRoundProgressView.h"

#import "PATransferCell.h"

@implementation PATransferCell

- (NSString *)formatedTime:(NSInteger)seconds;
{
    if (seconds < 20) {
        return NSLocalizedString(@"a few seconds", nil);
    } else if (seconds < 60) {
        return NSLocalizedString(@"less then a minute", nil);
    } else if (seconds < 120) {
        return NSLocalizedString(@"one minute", nil);
    }  else if (seconds < 3600) {
        NSInteger minutes = floorf(seconds / 60.0);
        return [NSString stringWithFormat:NSLocalizedString(@"%i minutes", nil), minutes];
    } else {
        NSInteger hours = floorf(seconds / 3600.0);
        seconds -= hours * 3600;
        NSInteger minutes = floorf(seconds / 60.0);
        return [NSString stringWithFormat:NSLocalizedString(@"%i h %i m", nil), hours, minutes];
    }
}

- (void)setTransfer:(PKTransfer *)transfer;
{
    if (transfer == _transfer) return;
    
    _transfer = transfer;
    
    self.textLabel.textColor = (transfer.transferStatus == PKTransferStatusCompleted ? [UIColor grayColor] : [UIColor blackColor]);
    self.textLabel.text = transfer.name;
    
    if (transfer.transferStatus != PKTransferStatusCompleted && transfer.transferStatus != PKTransferStatusQueued && transfer.transferStatus != PKTransferStatusDownloading) {
        self.detailTextLabel.text = transfer.statusMessage;
    }
    
    if (transfer.transferStatus == PKTransferStatusDownloading) {
        LSRoundProgressView *progressView = [[LSRoundProgressView alloc] initWithFrame:CGRectMake(0.0, 0.0, 38.0, 38.0)];
        progressView.alpha = 1.0;
        progressView.progress = [transfer.percentDone floatValue] / 100.0;
        self.accessoryView = progressView;
        
        NSInteger secondsRemaining = [transfer.estimatedTime integerValue];
        NSString *remainingString;
        if (secondsRemaining <= 0) {
            remainingString = @"∞";
        } else {
            remainingString = [self formatedTime:secondsRemaining];
        }
        
        self.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ remaining", nil), remainingString];
    }

    if (transfer.transferStatus == PKTransferStatusCompleted) {
        self.imageView.image = [[UIImage imageNamed:@"CheckMark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.imageView.tintColor = self.textLabel.textColor;
    }
}

@end
