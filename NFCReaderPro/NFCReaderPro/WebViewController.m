//
//  WebViewController.m
//  NFCReaderPro
//
//  Created by 金玉衡 on 16/11/21.
//
//

#import "WebViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface WebViewController() <UIWebViewDelegate>

@property (nonatomic, strong)UIWebView *webView;

@end

@implementation WebViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [self addUIConstraints];
    [self setUpNavigationBar];
    self.title = @"页面";
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showWebView];
}


- (void)addUIConstraints
{
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.view);
    }];
}

- (void)setUpNavigationBar
{
    UIBarButtonItem *seperatorBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    seperatorBarItem.width = -10;
    
    UIBarButtonItem *backBar = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backup)];
    
    UIBarButtonItem *imageBack = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back_white"]]];
    
    self.navigationItem.leftBarButtonItems = @[imageBack, backBar];
}

- (void)showWebView
{
    //NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"index.html" withExtension:nil];
    NSURL *htmlURL = [NSURL URLWithString:self.strUrl];
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
        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _webView.delegate = self;
        
    }
    
    return _webView;
}


- (void)backup
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    
   // [self addCustomActions];
}

#pragma mark - private method
- (void)addCustomActions
{
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    [context evaluateScript:@"var arr = [3, 4, 'abc'];"];
    
    [self addPayActionWithContext:context];
    
   
}

- (void)addScanActionWithContext:(JSContext *)context
{
    context[@"scan"] = ^(){
        
        
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
