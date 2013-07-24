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

- (void)setTransfer:(PKTransfer *)transfer;
{
    if (transfer == _transfer) return;
    
    _transfer = transfer;
    
    self.textLabel.textColor = (transfer.transferStatus == PKTransferStatusCompleted ? [UIColor grayColor] : [UIColor blackColor]);
    self.textLabel.text = transfer.name;
    
    if (transfer.transferStatus != PKTransferStatusCompleted && transfer.transferStatus != PKTransferStatusQueued) {
        self.detailTextLabel.text = transfer.statusMessage;
    }
    
    if (transfer.transferStatus == PKTransferStatusDownloading) {
        LSRoundProgressView *progressView = [[LSRoundProgressView alloc] initWithFrame:CGRectMake(0.0, 0.0, 38.0, 38.0)];
        progressView.progress = [transfer.percentDone floatValue] / 100.0;
        self.accessoryView = progressView;
    }

}

@end
