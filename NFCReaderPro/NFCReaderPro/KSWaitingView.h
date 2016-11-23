//
//  KSWaitingView.h
//  ManagerTool
//
//  Created by KingYH on 16/4/15.
//  Copyright © 2016年 FT EnterSafe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSWaitingView : UIWindow


@property (nonatomic, assign) int timeout;

@property (nonatomic, strong) void (^CardReaderCompletionBlock)(NSString *strURL);

@property (nonatomic, strong) NSString *strInputData;

@property(nonatomic, assign) CFRunLoopRef currentRunLoop;

-(void)show;

-(void)hide;


@end
