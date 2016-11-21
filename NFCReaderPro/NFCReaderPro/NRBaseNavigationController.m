//
//  COBaseNavigationController.m
//  CoMoBicycle
//
//  Created by 金玉衡 on 16/11/14.
//  Copyright © 2016年 AutoMo. All rights reserved.
//

#import "NRBaseNavigationController.h"

@interface NRBaseNavigationController()

@end

@implementation NRBaseNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //动态更改导航背景/样式
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setBarTintColor:navigaterBarColor];
    
    [bar setTranslucent:NO];
    
    [bar setTintColor:[UIColor whiteColor]];
    
    [bar setTitleTextAttributes:@{
                                  NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:16]
                                  }];
    //导航条中按钮的颜色
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    [item setTitleTextAttributes:@{
                                   NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:16]
                                   }forState:UIControlStateNormal];
    
    

}

//更改状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


//设置状态栏是否隐藏
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
