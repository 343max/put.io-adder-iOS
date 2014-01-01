//
//  PAFileView.h
//  put.io adder
//
//  Created by Thomas Kollbach on 20.10.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PAMP4ConversionView;


@interface PAFileView : UIScrollView

@property (readonly) UIView *viedoPlayerContainerView;
@property (readonly) UIImageView *headerImageView;
@property (readonly) UILabel *titleLabel;
@property (readonly) PAMP4ConversionView *conversionView;
@property (readwrite) UIEdgeInsets textIndsets;

@end
