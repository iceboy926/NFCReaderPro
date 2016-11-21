//
//  KSWaitingView.h
//  ManagerTool
//
//  Created by KingYH on 16/4/15.
//  Copyright © 2016年 FT EnterSafe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSWaitingView : UIView


@property (nonatomic, assign) int timeout;

@property (nonatomic, strong) void (^CardReaderWaittingBlock)();

-(void)show;

-(void)hide;


@end
