//
//  PAFileView.h
//  put.io adder
//
//  Created by Thomas Kollbach on 20.10.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAFileView : UIScrollView

@property (readonly) UIView *viedoPlayerContainerView;
@property (readonly) UIImageView *headerImageView;
@property (readonly) UILabel *titleLabel;
@property (readwrite) UIEdgeInsets textIndsets;

@end
