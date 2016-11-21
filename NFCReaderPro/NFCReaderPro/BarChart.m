//
//  BarChart.m
//  Xhacker
//
//  Created by Xhacker on 2013-07-25.
//  Copyright (c) 2013 Xhacker. All rights reserved.
//

#import "BarChart.h"

@implementation BarChart

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self loadDefaults];
    }
    return self;
}

- (void)loadDefaults
{
    self.opaque = NO;
    
    _barColor = [UIColor colorWithRed:56.0/255 green:45.0/255 blue:244.0/255 alpha:1];
    _barSpacing = 2;
    _backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    _roundToPixel = YES;
    _barWidth = 3;
    _backgroundBarNum = 5;
    _barNum = 0;
}

- (void)drawRect:(CGRect)rect
{    
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat barMaxHeight = CGRectGetHeight(rect);
    CGFloat barWidth = _barWidth;
    
    for (NSInteger i = 0; i < _backgroundBarNum; i += 1) {
        
        CGFloat x = i * (barWidth + self.barSpacing);
        CGFloat y = barMaxHeight - barMaxHeight * (i+1) / _backgroundBarNum;
        CGFloat width = barWidth;
        CGFloat height = barMaxHeight * (i+1) / _backgroundBarNum;
        
        if (height > barMaxHeight) {
            height = barMaxHeight;
        }
        if (self.roundToPixel) {
            height = (int)height;
        }

        
        [self.backgroundColor setFill];
        
        CGRect backgroundRect = CGRectMake(x, y, width, height);
        CGContextFillRect(context, backgroundRect);

    }
    
    for (NSInteger i = 0; i < _barNum; i += 1) {
        
        CGFloat x = i * (barWidth + self.barSpacing);
        CGFloat y = barMaxHeight - barMaxHeight * (i+1) / _backgroundBarNum;
        CGFloat width = barWidth;
        CGFloat height = barMaxHeight * (i+1) / _backgroundBarNum;
        
        if (height > barMaxHeight) {
            height = barMaxHeight;
        }
        if (self.roundToPixel) {
            height = (int)height;
        }
        
        //[NSThread sleepForTimeInterval:0.4];

        
        [self.barColor setFill];
        
        CGRect barRect = CGRectMake(x, y, width, height);
        CGContextFillRect(context, barRect);
    }
}

#pragma mark Setters


- (void)setBarColor:(UIColor *)barColor
{
    _barColor = barColor;
    [self setNeedsDisplay];
}

- (void)setBarSpacing:(NSInteger)barSpacing
{
    _barSpacing = barSpacing;
    [self setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    [self setNeedsDisplay];
}

- (void)setBarWidth:(NSInteger)barWidth
{
    _barWidth = barWidth;
    [self setNeedsDisplay];
}

- (void)setBackgroundBarNum:(NSInteger)backgroundBarNum
{
    _backgroundBarNum = backgroundBarNum;
    [self setNeedsDisplay];
}

- (void)setBarNum:(NSInteger)barNum
{
    _barNum = barNum;
    [self setNeedsDisplay];
}

@end
