//
//  MainWebViewController.m
//  NFCReaderPro
//
//  Created by 金玉衡 on 16/11/23.
//
//

#import "MainWebViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "ListSelectView.h"
#import "KSWaitingView.h"

@interface MainWebViewController()<UIWebViewDelegate>

@property (nonatomic, strong)UIWebView *webView;
@property (nonatomic, strong) ListSelectView *listView;
@property (nonatomic, strong) KSWaitingView *waitingView;

@end


@implementation MainWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.webView];
    
    [self setupNavigationView];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showWebView];
}


- (void)setupNavigationView
{
    self.view.backgroundColor = backGroundColor;
    [self setTitle:@"NFCReader"];
}

- (void)showWebView
{
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"index.html" withExtension:nil];
    //NSURL *htmlURL = [NSURL URLWithString:self.strUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:htmlURL];
    
    self.webView.backgroundColor = [UIColor clearColor];
    // UIWebView 滚动的比较慢，这里设置为正常速度
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.webView loadRequest:request];
}



- (UIWebView *)webView
{
    if(_webView == nil)
    {
        _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
        
        _webView.delegate = self;
    }
    
    return _webView;
}

- (KSWaitingView *)waitingView
{
    if(_waitingView == nil)
    {
        _waitingView = [[KSWaitingView alloc] init];
    }
    return _waitingView;
}


- (void)showListView
{
    self.listView = [[ListSelectView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.listView.isShowCancelBtn = YES;
    self.listView.isShowSureBtn = NO;
    self.listView.isShowTitle = YES;
    
    WEAK_SELF(weakself)
    [self.listView addTitleString:@"蓝牙设备" animated:YES completionHandler:^(BOOL blConnect) {
        //[sender setTitle:string forState:UIControlStateNormal];
        
        [weakself showWait:@"正在连接.."];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakself hideWait];
            
            if(blConnect)
            {
                [weakself showAlert:@"连接设备成功"];
                //[self getDeviceMsg];
            }
            else
            {
                [weakself showAlert:@"连接设备失败"];
            }
            
        });
        
        
    } withSureButtonBlock:^{
        
        
        
    }];
    
    
}

- (void)readerCardBtnClickedWithInputStr:(NSString *)strInput
{
    NSString *outData = [strInput stringByTrimmingCharactersInSet:[NSMutableCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([DKBleManager sharedInstance].isConnect)
    {
        self.waitingView.strInputData = outData;
        
        [self.waitingView show];
        
        self.waitingView.CardReaderCompletionBlock = ^(NSString *strURL){
            
            NSLog(@"out data is %@", strURL);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
            
        };
    }
    else
    {
        [self showAlert:@"请先连接蓝牙读卡器"];
    }
}



-(void)showAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    
}

-(void)showWait:(NSString *)mas
{
    [SVProgressHUD showWithStatus:mas];
}

-(void)hideWait
{
    [SVProgressHUD dismiss];
}




#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    
     [self addCustomActions];
}


#pragma mark - private method
- (void)addCustomActions
{
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    [context evaluateScript:@"var arr = [3, 4, 'abc'];"];
    
    [self addScanActionWithContext:context];
    
    [self addCardReaderActionWithContext:context];
    
}

- (void)addScanActionWithContext:(JSContext *)context
{
    WEAK_SELF(weakself)
    context[@"scan"] = ^(){
        
        [weakself showListView];
    };
}

- (void)addCardReaderActionWithContext:(JSContext *)context
{
    WEAK_SELF(weakself)
    context[@"CardReader"] = ^(NSString *strUrl)
    {
        [weakself readerCardBtnClickedWithInputStr:strUrl];
    };
}


- (void)addPayActionWithContext:(JSContext *)context
{
    context[@"payAction"] = ^() {
        NSArray *args = [JSContext currentArguments];
        
        if (args.count < 4) {
            return ;
        }
        
        NSString *orderNo = [args[0] toString];
        NSString *channel = [args[1] toString];
        long long amount = [[args[2] toNumber] longLongValue];
        NSString *subject = [args[3] toString];
        
        // 支付操作
        NSLog(@"orderNo:%@---channel:%@---amount:%lld---subject:%@",orderNo,channel,amount,subject);
        
        // 将支付结果返回给js
        //        NSString *jsStr = [NSString stringWithFormat:@"payResult('%@')",@"支付成功"];
        //        [[JSContext currentContext] evaluateScript:jsStr];
        [[JSContext currentContext][@"payResult"] callWithArguments:@[@"支付成功"]];
    };
}

- (void)addShakeActionWithContext:(JSContext *)context
{
    
    context[@"shake"] = ^() {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    };
}

- (void)addGoBackWithContext:(JSContext *)context
{
    __weak typeof(self) weakSelf = self;
    context[@"goBack"] = ^() {
        [weakSelf.webView goBack];
    };
}


@end
