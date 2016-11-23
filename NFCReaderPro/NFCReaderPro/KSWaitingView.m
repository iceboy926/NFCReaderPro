//
//  KSWaitingView.m
//  ManagerTool
//
//  Created by KingYH on 16/4/15.
//  Copyright © 2016年 FT EnterSafe. All rights reserved.
//

#import "KSWaitingView.h"
#import "NFCCard.h"
#import "NSData+Hex.h"

#define KSMessageBoxFrame CGRectMake(0.0f, 0.0f, 280.0f, 180.0f)

@interface KSWaitingView()
{
    UIView *_mask;
    UIView *_messageBg;
    UIActivityIndicatorView *_indicator;
    UILabel *_messageLabel;
    NSLock *locker;
}

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) DKDeviceManager  *deviceManager;

@end



@implementation KSWaitingView




-(id)init
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self = [super initWithFrame:window.bounds];
    if(self)
    {
        self.windowLevel = UIWindowLevelNormal;
        self.backgroundColor = [UIColor clearColor];
        
        self.backgroundColor = [UIColor clearColor];
        
        UIView *mask = [[UIView alloc] initWithFrame:self.bounds];
        mask.backgroundColor =  [UIColor blackColor];
        mask.alpha = 0;
        _mask = mask;
        [self addSubview:mask];
        
        
        UIView *messageBoxBg = [[UIView alloc] initWithFrame:KSMessageBoxFrame];
        messageBoxBg.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.0f);
//        messageBoxBg.image = [[UIImage imageNamed:@"alert_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        messageBoxBg.layer.shadowColor = [UIColor blackColor].CGColor;
        messageBoxBg.layer.shadowOffset = CGSizeMake(0, 0);
        messageBoxBg.layer.shadowRadius = 5.0f;
        messageBoxBg.layer.shadowOpacity = 0.2;
        messageBoxBg.layer.shouldRasterize = YES;
        
        messageBoxBg.backgroundColor = [UIColor whiteColor];
        
        _messageBg = messageBoxBg;
        [self addSubview:messageBoxBg];
        
        _indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        CGRect frame = _indicator.frame;
        frame.origin.x = (CGRectGetWidth(_messageBg.frame) - CGRectGetWidth(frame))/2.0f;
        frame.origin.y = 30.0f;
        _indicator.frame = frame;
        [_messageBg addSubview:_indicator];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, CGRectGetMaxY(_indicator.frame) + 10.0f, 240.0f, 36.0f)];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.font = [UIFont systemFontOfSize:14.0f];
        messageLabel.numberOfLines = 2;
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;//UILineBreakModeWordWrap;
        _messageLabel = messageLabel;
        [_messageBg addSubview:messageLabel];
        
        _timeout = 10;
        
        _deviceManager = [[DKDeviceManager alloc] init];
        
        locker = [[NSLock alloc] init];
        
    }
    
    
    return self;
}



-(void)show
{
    self.hidden = NO;
    
    self.messageLabel.text = @"等待读卡操作......";
    self.messageLabel.textColor = [UIColor blackColor];
    
    _mask.alpha = 0;
    [UIView animateWithDuration:0.1 animations:^{
       
        _mask.alpha = 0.4f;
        
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    }];
    _messageBg.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.5],
                              [NSNumber numberWithFloat:1.2],
                              [NSNumber numberWithFloat:0.9],
                              [NSNumber numberWithFloat:1.0], nil];
    bounceAnimation.duration = 0.4f;
    bounceAnimation.removedOnCompletion = NO;
    [_messageBg.layer addAnimation:bounceAnimation forKey:@"bounce"];
    
    [_indicator startAnimating];

     self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
}

-(void)hide
{
    _mask.alpha = 0.2;
    [_timer invalidate];
    [UIView animateWithDuration:0.1 animations:^{
        _mask.alpha = 0.0f;
    }];
    
    
    _messageBg.layer.transform = CATransform3DMakeScale(0.0, 0.0, 1.0);
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:1.0],
                              [NSNumber numberWithFloat:1.1],
                              [NSNumber numberWithFloat:0.5],
                              [NSNumber numberWithFloat:0.0], nil];
    bounceAnimation.duration = 0.3f;
    bounceAnimation.removedOnCompletion = NO;
    bounceAnimation.delegate = self;
    [_messageBg.layer addAnimation:bounceAnimation forKey:@"hidebounce"];
    
    //_messageBg.layer.transform = CATransform3DIdentity;
    [_indicator stopAnimating];
    
    self.hidden = YES;
    
}

- (void)refresh:(NSTimer *)timer
{
    WEAK_SELF(weakself)
    [self.deviceManager requestRfmSearchCard:DKCardTypeDefault callbackBlock:^(BOOL isblnIsSus, DKCardType cardType, NSData *CardSn, NSData *bytCarATS) {
    
        if(isblnIsSus)
        {
            NSLog(@"read card OK..card type is %d", cardType);
            
            if (cardType == DKIso14443A_CPUType)
            {
                CpuCard *card = [self.deviceManager getCard];
                if(card != nil)
                {
                    [card apduExchange:[NFCCard getSelectMainFileCmdByte] callback:^(BOOL isCmdRunSuc, NSData *apduRtnData){
                    
                        if(isCmdRunSuc)
                        {
                            [card apduExchange:[NFCCard readCmdByte] callback:^(BOOL isCmdRunSuc, NSData *apduRtnData){
                                
                                if(isCmdRunSuc)
                                {
                                    
                                    NSString *strOut = [apduRtnData hexadecimalString];
                                    
                                    NSLog(@" read out data is %@", strOut);
                                    
                                    NSData *dataSend = [NFCCard writeCmdByteWithString:self.strInputData];
                                    [card apduExchange:dataSend callback:^(BOOL isCmdRunSuc, NSData *apduRtnData){
                                        
                                        if(isCmdRunSuc)
                                        {
                                            
                                            [card apduExchange:[NFCCard readCmdByte] callback:^(BOOL isCmdRunSuc, NSData *apduRtnData){
                                                
                                                
                                                NSString *strOut = [apduRtnData hexadecimalString];
                                                
                                                NSLog(@"DKIso14443A_CPUType read out data is %@", strOut);
                                                
                                                int len = strOut.length - 4;
                                                
                                                NSString *stroutData = [strOut substringToIndex:len];
                                                
                                                NSLog(@"DKIso14443A_CPUType read out data is %@", stroutData);
                                                
                                                NSData *dataout = [NSData dataWithHexString:stroutData];
                                                
                                                NSString *strurl = [[NSString alloc] initWithData:dataout encoding:NSUTF8StringEncoding];
                                                
                                                NSLog(@"strurl = %@", strurl);
                                                
                                                
                                                
                                                [card close];
                                                
                                                [_indicator stopAnimating];
                                                weakself.messageLabel.text = @"读卡成功";
                                                weakself.messageLabel.textColor = [UIColor redColor];
                                                
                                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                
                                                    [weakself hide];
                                                    
                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strurl]];
                                                });
                                            }];
                                        }
                                        
                                    }];
                                }
                            }];
                        }
                    }];
                }
                
            }
            else if (cardType == DKIso14443B_CPUType)
            {
                
            }
            else if (cardType == DKFeliCa_Type)
            {
                
            }
            else if (cardType == DKUltralight_type)
            {
            }
            else if (cardType == DKMifare_Type)
            {
                
            }
            
        }
    }];
    
}


@end
