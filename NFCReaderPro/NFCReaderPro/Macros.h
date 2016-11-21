//
//  Macros.h
//  NFCReaderPro
//
//  Created by 金玉衡 on 16/11/21.
//
//

#ifndef Macros_h
#define Macros_h

#define MAX_WIDTH  [UIScreen mainScreen].bounds.size.width
#define MAX_HEIGHT [UIScreen mainScreen].bounds.size.height
#define WIDTH_TO_FIT(_width)  (ceilf( [UIScreen mainScreen].bounds.size.width / 414.0f  * (_width / 2) * 2))

#define WEAK_SELF(weakSelf) __weak __typeof(&*self)weakSelf = self;
#define STRONG_SELF(strongSelf) __strong __typeof(&*self)strongSelf = self;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 green:((float)(((rgbValue) & 0xFF00) >> 8))/255.0 blue:((float)((rgbValue) & 0xFF))/255.0 alpha:1.0]


#define ISIOS10 ([[[UIDevice currentDevice] sysytemVersion] doubleValue]>=10.0)
#define ISIOS9 ([[[UIDevice currentDevice] systemVersion] doubleValue]>=9.0)
#define ISIOS8 ([[[UIDevice currentDevice] systemVersion] doubleValue]>=8.0)
#define ISIOS7 ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)


#pragma mark color

#define customButtonColor   UIColorFromRGB(0xF89022)
#define backGroundColor     UIColorFromRGB(0xEFEFEF)
#define navigaterBarColor   UIColorFromRGB(0x575757)
#define shadowViewColor     UIColorFromRGB(0xB0B0B0)
#define orangeViewColor     UIColorFromRGB(0xEE9572)


#pragma mark frame

#define NavBarHeight        64
#define ButtonHeight        44



#endif /* Macros_h */
