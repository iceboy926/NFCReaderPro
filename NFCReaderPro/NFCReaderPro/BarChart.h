//
//  BarChart.h
//  Xhacker
//
//  Created by Xhacker on 2013-07-25.
//  Copyright (c) 2013 Xhacker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarChart : UIView


@property (nonatomic) NSInteger backgroundBarNum;

@property (nonatomic) NSInteger barNum;

@property (nonatomic) UIColor *barColor;
@property (nonatomic) NSInteger barSpacing;
@property (nonatomic) NSInteger barWidth;
@property (nonatomic) UIColor *backgroundColor;

// Round bar height to pixel for sharper chart
@property (nonatomic) BOOL roundToPixel;

@end
