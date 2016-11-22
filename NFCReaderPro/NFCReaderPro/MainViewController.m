//
//  ViewController.m
//  NFCReaderPro
//
//  Created by 金玉衡 on 16/11/21.
//
//

#import "MainViewController.h"
#import "ScanDeviceListViewController.h"
#import "WebViewController.h"
#import "KSWaitingView.h"
#import "NFCCard.h"
#import "NSData+Hex.h"

@interface MainViewController ()

@property (nonatomic, strong)UIButton *bleManagerBtn;
@property (nonatomic, strong) DKDeviceManager  *deviceManager;
@property (nonatomic, strong) NSMutableString  *msgBuffer;
@property (nonatomic, strong)UITextView *msgTextView;
@property (nonatomic, strong) UITextField *inputTextView;
@property (nonatomic, strong) UIButton *readerCardBtn;
@property (nonatomic, strong) KSWaitingView *waitingView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self.view addSubview:self.bleManagerBtn];
    [self.view addSubview:self.msgTextView];
    [self.view addSubview:self.readerCardBtn];
    [self.view addSubview:self.inputTextView];

    [self setupNavigationView];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addUIConstraints];
}


- (void)setupNavigationView
{
    self.view.backgroundColor = backGroundColor;
    [self setTitle:@"NFCReader"];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ui layout

- (void)addUIConstraints
{
    [self.bleManagerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(10);
        make.size.mas_equalTo(CGSizeMake(150, 50));
        
    }];
    
    [self.msgTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_bleManagerBtn.mas_bottom).offset(10);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.3);
    }];
    
    [self.readerCardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_msgTextView.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(150, 50));
        
    }];
    
    [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_readerCardBtn.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(280, 50));
    }];
}

#pragma mark lazy load

- (UIButton *)bleManagerBtn
{
    if(_bleManagerBtn == nil)
    {
        _bleManagerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_bleManagerBtn setTitle:@"查找蓝牙设备" forState:UIControlStateNormal];
        [_bleManagerBtn setTitleColor:navigaterBarColor forState:UIControlStateNormal];
        [_bleManagerBtn setBackgroundColor:[UIColor clearColor]];
        
        [_bleManagerBtn addTarget:self action:@selector(bleManangerClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _bleManagerBtn;
}

- (UITextView *)msgTextView
{
    if(_msgTextView == nil)
    {
        _msgTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        
        _msgTextView.textColor = navigaterBarColor;

    }
    
    return _msgTextView;
}

- (UITextField *)inputTextView
{
    if(_inputTextView == nil)
    {
        _inputTextView = [[UITextField alloc] init];
        _inputTextView.textAlignment = NSTextAlignmentCenter;
        _inputTextView.text = @"http://www.baidu.com";
         //[[ UIApplication sharedApplication] openURL:[ NSURL urlWithString:urlText];
    }
    
    return _inputTextView;
}

- (UIButton *)readerCardBtn
{
    if(_readerCardBtn == nil)
    {
        _readerCardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_readerCardBtn setTitle:@"读卡操作" forState:UIControlStateNormal];
        [_readerCardBtn setTitleColor:navigaterBarColor forState:UIControlStateNormal];
        [_readerCardBtn setBackgroundColor:[UIColor clearColor]];
        [_readerCardBtn addTarget:self action:@selector(readerCardBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _readerCardBtn;
}

- (DKDeviceManager *)deviceManager
{
    if(_deviceManager == nil)
    {
        _deviceManager = [[DKDeviceManager alloc] init];
        
    }
    
    return _deviceManager;
}

- (NSMutableString *)msgBuffer
{
    if(_msgBuffer == nil)
    {
        _msgBuffer = [[NSMutableString alloc] init];
    }
    
    return _msgBuffer;
}

- (KSWaitingView *)waitingView
{
    if(_waitingView == nil)
    {
        _waitingView = [[KSWaitingView alloc] init];
    }
    return _waitingView;
}


#pragma mark 

- (void)bleManangerClicked:(UIButton *)sender
{
    
    ScanDeviceListViewController *scanDeviceVC = [[ScanDeviceListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    scanDeviceVC.title = @"蓝牙设备";
    
    scanDeviceVC.DidCheckBLEDevice = ^(BOOL blConnect){
    
        [self showWait:@"正在连接设备"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
            [self hideWait];
        
            if(blConnect)
            {
                [self showAlert:@"连接设备成功"];
                [self getDeviceMsg];
            }
            else
            {
                [self showAlert:@"连接设备失败"];
            }

        });
       };
    
    [self.navigationController pushViewController:scanDeviceVC animated:YES];
}


- (void)readerCardBtnClicked:(UIButton *)sender
{
    //WebViewController *webVC = [[WebViewController alloc] init];
    //webVC.title = @"";
    
    //[self.navigationController pushViewController:webVC animated:YES];
    
    if([DKBleManager sharedInstance].isConnect)
    {
        self.waitingView.strInputData = self.inputTextView.text;
    
        [self.waitingView show];
    }
    else
    {
        [self showAlert:@"请先连接蓝牙读卡器"];
    }
}

-(void)showWaitView
{
    __block KSWaitingView *waitView = [[KSWaitingView alloc] init];
    waitView.strInputData = self.inputTextView.text;
    [waitView show];
    
    __block BOOL complete = NO;
//    PFN_CALLBACK_GetTranSignature callback = param->pfn_CallBack_GetTranSignature;
//    [GCDHelper dispatchBlock:^{
//        if (callback) {
//            ret = callback(param->pbSignedData, param->pulSignedDataLen);
//        }
//        
//    } complete:^{
//        
//        complete = YES;
//        if (waitView.currentRunLoop) {
//            waitView.ret = ret;
//            CFRunLoopStop(waitView.currentRunLoop);
//        }
//        
//    }];
    
    
    
    [self readerCardActionWithComplete:^(NSString *strOutData){
        
        complete = YES;
        
        NSLog(@"\n read out data is %@ \n", strOutData);
        
        if(waitView.currentRunLoop)
        {
            CFRunLoopStop(waitView.currentRunLoop);
        }
        
    }];
    
    if (!complete) {
        waitView.currentRunLoop = CFRunLoopGetCurrent();
        CFRunLoopRun();
    }
    
    [waitView hide];
}


- (void)readerCardActionWithComplete:(void(^)(NSString *strOutData))completion
{
    
    [self.deviceManager requestRfmSearchCard:DKIso14443A_CPUType callbackBlock:^(BOOL isblnIsSus, DKCardType cardType, NSData *CardSn, NSData *bytCarATS) {
        
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
                            NSData *dataSend = [NFCCard writeCmdByteWithString:self.inputTextView.text];
                            [card apduExchange:dataSend callback:^(BOOL isCmdRunSuc, NSData *apduRtnData){
                                
                                if(isCmdRunSuc)
                                {
                                    
                                    [card apduExchange:[NFCCard readCmdByte] callback:^(BOOL isCmdRunSuc, NSData *apduRtnData){
                                        
                                        
                                        NSString *strOut = [apduRtnData hexadecimalString];
                                        
                                        //NSLog(@"read out data is %@", strOut);
                                        
                                        if(completion)
                                        {
                                            completion(strOut);
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
                Ntag21x *card = [self.deviceManager getCard];
                if (card != nil) {
                    //                    [self.msgBuffer setString:@"寻到Ultralight卡 －>UID:"];
                    //                    [self.msgBuffer appendString:[NSString stringWithFormat:@"%@\r\n", card.uid]];
                    //                    dispatch_async(dispatch_get_main_queue(), ^{
                    //                        self.msgTextView.text = self.msgBuffer;
                    //                    });
                    //                    //发送读块0数据
                    //                    [self.msgBuffer appendString:[NSString stringWithFormat:@"\r\n读块0\r\n"]];
                    //                    self.msgTextView.text = self.msgBuffer;
                    [card ultralightRead:0 callbackBlock:^(BOOL isSuc, NSData *returnData) {
                        if (isSuc) {
                            
                            NSLog(@"返回:%@\r\n", returnData);
                            //                            [self.msgBuffer appendString:[NSString stringWithFormat:@"返回:%@\r\n", returnData]];
                            //                            dispatch_async(dispatch_get_main_queue(), ^{
                            //                                self.msgTextView.text = self.msgBuffer;
                            //                            });
                            
                            
                            if(completion)
                            {
                                completion([NSString stringWithFormat:@"返回：%@\r\n", returnData]);
                            }

                        }
                        
                        [card close];
                    }];
                }
                
                
            }
            else if (cardType == DKMifare_Type)
            {
                
            }
            
            
            
        }
    }];
    

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


//获取设备信息
-(void)getDeviceMsg {
    
    [self.msgBuffer setString:@""];
    self.msgTextView.text = @"";
    [self.deviceManager requestDeviceVersionWithCallbackBlock:^(NSUInteger versionNum) {
        [self.msgBuffer appendString:@"SDK版本v1.4.0 20161026\r\n"];
        [self.msgBuffer appendString:[NSString stringWithFormat:@"设备版本：%02lx\r\n", (unsigned long)versionNum]];
        self.msgTextView.text = self.msgBuffer;
        [self.deviceManager requestDeviceBtValueWithCallbackBlock:^(float btVlueMv) {
            [self.msgBuffer appendString:[NSString stringWithFormat:@"设备电池电压：%.2fV\r\n", btVlueMv]];
            if (btVlueMv < 3.4) {
                [self.msgBuffer appendString:@"设备电池电量低，请及时充电！\r\n"];
            }
            else {
                [self.msgBuffer appendString:@"设备电池电量充足！\r\n"];
            }
            self.msgTextView.text = self.msgBuffer;
        }];
    }];
}



@end
