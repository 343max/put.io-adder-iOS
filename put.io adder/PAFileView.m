//
//  PAFileView.m
//  put.io adder
//
//  Created by Thomas Kollbach on 20.10.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PAFileView.h"

@interface PAFileView ()

@property (readwrite) UIView *viedoPlayerContainerView;
@property (readwrite) UIImageView *headerImageView;
@property (readwrite) UILabel *titleLabel;

@end

@implementation PAFileView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alwaysBounceVertical = YES;
        _textIndsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        _viedoPlayerContainerView = [[UIView alloc] initWithFrame:self.bounds];
        _viedoPlayerContainerView.backgroundColor = [UIColor redColor];
        [self addSubview:_viedoPlayerContainerView];
        
        _headerImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_headerImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [self addSubview:_titleLabel];
    }
    return self;
}


- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    CGPoint offset = CGPointMake(CGRectGetWidth(self.bounds), 0);
    
    self.viedoPlayerContainerView.frame = CGRectMake(0,
                                                     0,
                                                     CGRectGetWidth(self.bounds),
                                                     CGRectGetWidth(self.bounds) * 9.0 / 16.0);
    offset.y = fmax(CGRectGetMaxY(self.viedoPlayerContainerView.frame), offset.y);
    
    self.headerImageView.frame = self.viedoPlayerContainerView.frame;
    offset.y = fmax(CGRectGetMaxY(self.headerImageView.frame), offset.y);
    
    CGRect textLayoutRect = UIEdgeInsetsInsetRect(self.bounds, self.textIndsets);
    textLayoutRect.origin.y = CGRectGetMaxY(self.viedoPlayerContainerView.frame) + self.textIndsets.top;
    self.titleLabel.frame = textLayoutRect;
    [self.titleLabel sizeToFit];

    offset.y = fmax(CGRectGetMaxY(self.titleLabel.frame), offset.y);
    
    offset.y += self.textIndsets.bottom;
    
    self.contentSize = CGSizeMake(offset.x, offset.y);
}

@end
