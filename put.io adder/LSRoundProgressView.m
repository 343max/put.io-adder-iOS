//
//  LSRoundProgressView.m
//  Listen
//
//  Created by Max Winde on 18.06.13.
//  Copyright (c) 2013 Max Winde. All rights reserved.
//

#import "LSRoundProgressView.h"

@implementation LSRoundProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat lineWidth = 3.0;
    CGFloat circleLineWidth = 1.0;
    CGSize viewSize = self.bounds.size;
    CGPoint center = CGPointMake(viewSize.width / 2.0, viewSize.height / 2.0);
    CGFloat progressRadius = center.x - lineWidth / 2.0;
    CGFloat circleRadius = center.x - circleLineWidth / 2.0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context); {
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetStrokeColorWithColor(context, [self.color CGColor]);
        
        CGContextBeginPath(context);
        CGContextAddArc(context, center.x, center.y, progressRadius, M_PI_2 * 3.0, M_PI_2 * 3.0 + M_PI * 2.0 * self.progress, 0);
        CGContextStrokePath(context);
        
        CGContextSetLineWidth(context, circleLineWidth);
        
        CGContextBeginPath(context);
        CGContextAddArc(context, center.x, center.y, circleRadius, 0, 2 * M_PI, 0);
        CGContextStrokePath(context);
        
    } CGContextRestoreGState(context);
}

- (void)setProgress:(float)progress;
{
    if (progress == _progress) return;
    
    BOOL wasHidden = _progress <= 0.0 || _progress >= 1.0;
    BOOL willBeHidden = progress <= 0.0 || progress >= 1.0;
    
    if (wasHidden && !willBeHidden) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1.0;
        }];
    } else if (!wasHidden && willBeHidden) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0.0;
        }];
    }
    
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setColor:(UIColor *)color;
{
    if ([color isEqual:_color]) return;
    _color = color;
    [self setNeedsDisplay];
}

@end
