//
//  AppDelegate.h
//  NFCReaderPro
//
//  Created by 金玉衡 on 16/11/21.
//
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "MainWebViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) MainViewController *mainVC;

@property (nonatomic, strong) MainWebViewController *mainwebVC;
@end

